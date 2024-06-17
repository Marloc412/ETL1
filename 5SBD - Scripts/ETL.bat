sqlcmd -S DESKTOP-H1G5PA3 -d Teste -E -i "C:\5SBD - Scripts\Scripts\Criacao de tabelas.sql" -o "C:\5SBD - Scripts\logs\Log_Criacao.txt"
pause
sqlcmd -S DESKTOP-H1G5PA3 -d Teste -Q "set nocount on; select * from Carga" -s ";" -W -w 999 -o "C:\5SBD - Scripts\Carga.csv"
pause
sqlcmd -S DESKTOP-H1G5PA3 -d Teste -E -i "C:\5SBD - Scripts\Scripts\Upload CSV.sql" -o "C:\5SBD - Scripts\logs\Log_Upload_CSV.txt"
pause
sqlcmd -S DESKTOP-H1G5PA3 -d Teste -E -i "C:\5SBD - Scripts\Scripts\insert da tabela tempararia.sql" -o "C:\5SBD - Scripts\logs\Log_Insert.txt"
pause
sqlcmd -S DESKTOP-H1G5PA3 -d Teste -E -i "C:\5SBD - Scripts\Scripts\Consulta e criacao da Tabela de Prioridade.sql" -o "C:\5SBD - Scripts\logs\ProcessarPedidosPendentes.log"