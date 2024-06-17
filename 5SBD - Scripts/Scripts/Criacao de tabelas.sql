USE Teste; -- Seleciona o banco de dados "Teste"

-- Criação da tabela temporária para importação dos dados do CSV caso não exista
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CargaTemporaria]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.CargaTemporaria (
        ID_Produto INT PRIMARY KEY,
        d_pedido INT,
        id_item_pedido INT,
        codigo_cliente VARCHAR(6),
        data_compra DATE,
        data_pagamento DATE,
        email_comprador VARCHAR(255),
        nome_comprador VARCHAR(255),
        cpf VARCHAR(14),
        telefone_comprador VARCHAR(20),
        SKU_Produto VARCHAR(50),
        nome_produto VARCHAR(255),
        quantidade_comprada INT,
        moeda VARCHAR(3),
        preco_item DECIMAL(10, 2),
        nivel_servico_envio VARCHAR(50),
        nome_destinatario VARCHAR(255),
        endereco_entrega1 VARCHAR(255),
        endereco_entrega2 VARCHAR(255),
        endereco_entrega3 VARCHAR(255),
        cidade_entrega VARCHAR(100),
        estado_entrega VARCHAR(100),
        codigo_postal_entrega VARCHAR(20),
        pais_entrega VARCHAR(100),
        numero_ioss VARCHAR(20)
    );
END;


-- Criação da tabela Cliente
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cliente]') AND type in (N'U'))
BEGIN
    CREATE TABLE Cliente (
        ID INT PRIMARY KEY IDENTITY,
        codigo_cliente VARCHAR(6), 
        Nome VARCHAR(255),
        CPF VARCHAR(14),
        Email VARCHAR(255),
        Telefone VARCHAR(20),
        EnderecoEntrega1 VARCHAR(255),
        EnderecoEntrega2 VARCHAR(255),
        EnderecoEntrega3 VARCHAR(255),
        CidadeEntrega VARCHAR(100),
        EstadoEntrega VARCHAR(100),
        CodigoPostalEntrega VARCHAR(20),
        PaisEntrega VARCHAR(100),
        NumeroIOSS VARCHAR(20)
    );
END;


-- Verifica se a tabela Pedido existe, caso não exista, cria a tabela
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Pedido]') AND type in (N'U'))
BEGIN
    CREATE TABLE Pedido (
        ID_Pedido INT IDENTITY(1,1) PRIMARY KEY,
        ID_Pedido_Carga INT,
        ID_Cliente INT,
        Data_Pedido DATE,
        Data_Pagamento DATE,
        NivelServicoEnvio VARCHAR(50),
        NomeDestinatario VARCHAR(255),
        Status VARCHAR(50), -- Adicionando a coluna Status
        FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID)
    );
END;



-- Verifica se a tabela Produto existe, caso não exista, cria a tabela
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Produto]') AND type in (N'U'))
BEGIN
    CREATE TABLE Produto (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    NomeProduto VARCHAR(255),
    SKU VARCHAR(50) UNIQUE,
    Preco DECIMAL(10,2)
);
END;


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemPedido]') AND type in (N'U'))
BEGIN
    CREATE TABLE ItemPedido (
        ID_Item INT PRIMARY KEY IDENTITY,
        ID_Pedido INT,
        ID_Produto INT,
        QuantidadeComprada INT,
        Moeda VARCHAR(3),
        FOREIGN KEY (ID_Pedido) REFERENCES Pedido(ID_Pedido),
        FOREIGN KEY (ID_Produto) REFERENCES Produto(ID)
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Estoque]') AND type in (N'U'))
BEGIN
    CREATE TABLE Estoque (
        ID_Estoque INT IDENTITY(1,1) PRIMARY KEY,
        SKU_Produto VARCHAR(50),
        Quantidade INT,
        FOREIGN KEY (SKU_Produto) REFERENCES Produto(SKU)
    );
END;



IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Atendimento]') AND type in (N'U'))
BEGIN
    CREATE TABLE Atendimento (
        ID_Atendimento INT PRIMARY KEY IDENTITY,
        ID_Pedido INT,
        ValorPedido DECIMAL(10, 2),
        Status VARCHAR(50),
        Data_Atendimento DATE,
        FOREIGN KEY (ID_Pedido) REFERENCES Pedido(ID_Pedido)
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Compra]') AND type in (N'U'))
BEGIN
    CREATE TABLE Compra (
        ID_Compra INT PRIMARY KEY IDENTITY,
        ID_Pedido INT,
        ID_Produto INT,
        Data_Compra DATE,
        Status VARCHAR(50),
        FOREIGN KEY (ID_Pedido) REFERENCES Pedido(ID_Pedido),
        FOREIGN KEY (ID_Produto) REFERENCES Produto(ID)
    );
END;

