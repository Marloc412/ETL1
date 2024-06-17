USE Teste;
GO

-- Excluir a procedure se existir
IF OBJECT_ID('ConsultarEInserirPedidoXClientes', 'P') IS NOT NULL
    DROP PROCEDURE ConsultarEInserirPedidoXClientes;
GO

-- Criar a procedure ConsultarEInserirPedidoXClientes
CREATE PROCEDURE ConsultarEInserirPedidoXClientes
AS
BEGIN
    -- Criar tabela temporária para armazenar o resultado da consulta de PedidoXClientes
    IF OBJECT_ID('tempdb..#PedidoXClientes') IS NOT NULL
        DROP TABLE #PedidoXClientes;

    CREATE TABLE #PedidoXClientes (
        ID_Pedido_Carga INT,
        SKU_Produto VARCHAR(50), -- Alterado para SKU_Produto
        QuantidadeComprada INT,
        ID_Cliente INT,
        Preco DECIMAL(10, 2),
        ValorTotal DECIMAL(10, 2)
    );

    -- Inserir dados na tabela temporária #PedidoXClientes
    INSERT INTO #PedidoXClientes (ID_Pedido_Carga, SKU_Produto, QuantidadeComprada, ID_Cliente, Preco, ValorTotal)
    SELECT DISTINCT
        ped.ID_Pedido_Carga,
        p.SKU, -- Alterado para SKU
        ip.QuantidadeComprada,
        ped.ID_Cliente,
        p.Preco,
        ip.QuantidadeComprada * p.Preco AS ValorTotal
    FROM ItemPedido ip
    JOIN Pedido ped ON ip.ID_Pedido = ped.ID_Pedido_Carga
    JOIN Produto p ON ip.ID_Produto = p.ID;

    -- Ordenar os resultados da tabela #PedidoXClientes pelo ValorTotal em ordem decrescente
    SELECT * INTO #PedidoXClientes_Ordered
    FROM #PedidoXClientes
    ORDER BY ValorTotal DESC;

    -- Consulta final da tabela temporária #PedidoXClientes agrupada pelo ID_Cliente
    SELECT ID_Cliente, SUM(QuantidadeComprada) AS QuantidadeTotal, SUM(ValorTotal) AS ValorTotal
    INTO #Atendimento
    FROM #PedidoXClientes_Ordered
    GROUP BY ID_Cliente;

    -- Processar os pedidos
    DECLARE @ID_Cliente INT, @ID_Pedido INT, @QuantidadeRequerida INT, @QuantidadeEstoque INT, @SKU_Produto VARCHAR(50);

    -- Percorrer os resultados da tabela temporária #Atendimento e processar os pedidos
    DECLARE cur3 CURSOR FOR
    SELECT ID_Cliente
    FROM #Atendimento;

    OPEN cur3;
    FETCH NEXT FROM cur3 INTO @ID_Cliente;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Obter pedidos para o cliente atual
        DECLARE cur4 CURSOR FOR
        SELECT ID_Pedido_Carga
        FROM Pedido
        WHERE ID_Cliente = @ID_Cliente;

        OPEN cur4;
        FETCH NEXT FROM cur4 INTO @ID_Pedido;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Verificar se é possível atender o pedido
            DECLARE @PodeAtender BIT = 1;
            DECLARE cur2 CURSOR FOR
            SELECT QuantidadeComprada, SKU_Produto
            FROM #PedidoXClientes_Ordered
            WHERE ID_Pedido_Carga = @ID_Pedido;
            OPEN cur2;
            FETCH NEXT FROM cur2 INTO @QuantidadeRequerida, @SKU_Produto;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Verificar estoque
                SELECT @QuantidadeEstoque = Quantidade
                FROM Estoque
                WHERE SKU_Produto = @SKU_Produto;

                IF @QuantidadeEstoque < @QuantidadeRequerida
                BEGIN
                    -- Não há estoque suficiente para atender o pedido
                    SET @PodeAtender = 0;
                    BREAK;
                END

                FETCH NEXT FROM cur2 INTO @QuantidadeRequerida, @SKU_Produto;
            END
            CLOSE cur2;
            DEALLOCATE cur2;

            IF @PodeAtender = 1
            BEGIN
                -- Atender o pedido
                DECLARE @ID_Produto INT; -- Adicionado para armazenar o ID do produto
                SELECT @ID_Produto = ID_Produto FROM ItemPedido WHERE ID_Pedido = @ID_Pedido;

                DECLARE cur5 CURSOR FOR
                SELECT QuantidadeComprada, SKU_Produto
                FROM #PedidoXClientes_Ordered
                WHERE ID_Pedido_Carga = @ID_Pedido;
                OPEN cur5;
                FETCH NEXT FROM cur5 INTO @QuantidadeRequerida, @SKU_Produto;
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    -- Atualizar estoque
                    UPDATE Estoque
                    SET Quantidade = Quantidade - @QuantidadeRequerida
                    WHERE SKU_Produto = @SKU_Produto;

                    FETCH NEXT FROM cur5 INTO @QuantidadeRequerida, @SKU_Produto;
                END
                CLOSE cur5;
                DEALLOCATE cur5;

                -- Atualizar status do pedido
                UPDATE Pedido
                SET Status = 'Atendido'
                WHERE ID_Pedido_Carga = @ID_Pedido;

                -- Inserir na tabela Compra com ID do produto
                INSERT INTO Compra (ID_Pedido, ID_Produto, Data_Compra, Status)
                VALUES (@ID_Pedido, @ID_Produto, GETDATE(), 'Atendido');

                -- Inserir na tabela Atendimento
                INSERT INTO Atendimento (ID_Pedido, ValorPedido, Status,                Data_Atendimento)
                VALUES (@ID_Pedido, (SELECT SUM(ValorTotal) FROM #PedidoXClientes_Ordered WHERE ID_Pedido_Carga = @ID_Pedido), 'Atendido', GETDATE());
            END
            ELSE
            BEGIN
                -- Não há estoque suficiente para atender o pedido
                -- Atualizar status do pedido para "Aguardando Compra"
                UPDATE Pedido
                SET Status = 'Aguardando Compra'
                WHERE ID_Pedido_Carga = @ID_Pedido;

                -- Inserir na tabela Compra
                INSERT INTO Compra (ID_Pedido, ID_Produto, Data_Compra, Status)
                VALUES (@ID_Pedido, @ID_Produto, GETDATE(), 'Aguardando Compra');

                -- Inserir na tabela Atendimento com status "Aguardando Compra"
                INSERT INTO Atendimento (ID_Pedido, ValorPedido, Status, Data_Atendimento)
                VALUES (@ID_Pedido, (SELECT SUM(ValorTotal) FROM #PedidoXClientes_Ordered WHERE ID_Pedido_Carga = @ID_Pedido), 'Aguardando Compra', GETDATE());
            END

            FETCH NEXT FROM cur4 INTO @ID_Pedido;
        END
        CLOSE cur4;
        DEALLOCATE cur4;

        FETCH NEXT FROM cur3 INTO @ID_Cliente;
    END
    CLOSE cur3;
    DEALLOCATE cur3;

    -- Exibir os resultados para verificação
    SELECT * FROM Atendimento;

END;
GO

-- Executar a procedure ConsultarEInserirPedidoXClientes
EXEC ConsultarEInserirPedidoXClientes;

