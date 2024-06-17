-- Inserção na tabela Cliente
INSERT INTO Cliente (
    codigo_cliente, 
    Nome, 
    CPF, 
    Email, 
    Telefone, 
    EnderecoEntrega1, 
    EnderecoEntrega2, 
    EnderecoEntrega3, 
    CidadeEntrega, 
    EstadoEntrega, 
    CodigoPostalEntrega, 
    PaisEntrega, 
    NumeroIOSS
)
SELECT 
    codigo_cliente AS CodigoCliente,
    nome_comprador AS Nome,
    cpf AS CPF,
    email_comprador AS Email,
    telefone_comprador AS Telefone,
    endereco_entrega1 AS EnderecoEntrega1,
    endereco_entrega2 AS EnderecoEntrega2,
    endereco_entrega3 AS EnderecoEntrega3,
    cidade_entrega AS CidadeEntrega,
    estado_entrega AS EstadoEntrega,
    codigo_postal_entrega AS CodigoPostalEntrega,
    pais_entrega AS PaisEntrega,
    numero_ioss AS NumeroIOSS
FROM (
    SELECT 
        codigo_cliente,
        nome_comprador,
        cpf,
        email_comprador,
        telefone_comprador,
        endereco_entrega1,
        endereco_entrega2,
        endereco_entrega3,
        cidade_entrega,
        estado_entrega,
        codigo_postal_entrega,
        pais_entrega,
        numero_ioss,
        ROW_NUMBER() OVER (PARTITION BY email_comprador ORDER BY d_pedido) AS RowNumber
    FROM CargaTemporaria
) AS CT
WHERE RowNumber = 1
AND NOT EXISTS (
    SELECT 1 
    FROM Cliente AS CL 
    WHERE CL.Email = CT.email_comprador
);


-- PRODUTO
INSERT INTO dbo.Produto (NomeProduto, Preco, SKU)
SELECT DISTINCT 
    nome_produto, 
    preco_item, 
    sku_produto
FROM (
    SELECT 
        nome_produto,
        preco_item,
        sku_produto,
        ROW_NUMBER() OVER (PARTITION BY sku_produto ORDER BY ID_Produto) AS RowNumber
    FROM CargaTemporaria
) AS CT
WHERE RowNumber = 1
AND NOT EXISTS (
    SELECT 1
    FROM dbo.Produto AS PR
    WHERE PR.SKU = CT.sku_produto
);


-- Pedido
INSERT INTO Pedido (ID_Pedido_Carga, ID_Cliente, Data_Pedido, NivelServicoEnvio, NomeDestinatario, Status)
SELECT CT.d_pedido, CL.ID, CT.data_compra, CT.nivel_servico_envio, CT.nome_destinatario, 'Pendente'
FROM CargaTemporaria CT
INNER JOIN Cliente CL ON CL.codigo_cliente = CT.codigo_cliente
WHERE NOT EXISTS (
    SELECT 1
    FROM Pedido P
    WHERE P.ID_Pedido_Carga = CT.d_pedido
);

-- Item do pedido
INSERT INTO ItemPedido (ID_Pedido, ID_Produto, QuantidadeComprada, Moeda)
SELECT 
    CT.d_pedido AS ID_Pedido,
    PR.ID AS ID_Produto,
    CT.quantidade_comprada AS QuantidadeComprada,
    CT.moeda AS Moeda
FROM 
    CargaTemporaria CT
INNER JOIN 
    Produto PR ON PR.SKU = CT.SKU_Produto;

-- Estoque 1
INSERT INTO Estoque (SKU_Produto, Quantidade)
VALUES
    ('SKU123', 5),
    ('SKU456', 5);

-- Estoque 1
INSERT INTO Estoque (SKU_Produto, Quantidade)
SELECT DISTINCT SKU, 0
FROM Produto
WHERE SKU NOT IN (SELECT SKU_Produto FROM Estoque)
GROUP BY SKU;









