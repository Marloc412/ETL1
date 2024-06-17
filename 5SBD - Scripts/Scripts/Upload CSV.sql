--Bulk Insert para importar dados do CSV para a tabela temporária
use Teste;
BULK INSERT dbo.CargaTemporaria
FROM 'C:\5SBD - Scripts\Carga.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);