CREATE TRIGGER dbo.lost_credits
ON dbo.takes
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Atualizar os créditos totais dos alunos afetados
    UPDATE s
    SET s.tot_cred = s.tot_cred - d.credits
    FROM student s
    INNER JOIN deleted d ON s.ID = d.ID
    INNER JOIN course c ON d.course_id = c.course_id;
    
    -- Verificar se algum aluno ficou com créditos negativos (respeitando o constraint check)
    IF EXISTS (
        SELECT 1 
        FROM student 
        WHERE tot_cred < 0
    )
    BEGIN
        RAISERROR('Atenção: Aluno com credito negativo', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;