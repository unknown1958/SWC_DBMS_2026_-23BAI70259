-- Create Table
CREATE TABLE StudentMarks (
    Sname VARCHAR(10),
    Sid CHAR(1),
    Marks INT
);

-- Insert Data
INSERT INTO StudentMarks VALUES
('A', 'X', 75),
('A', 'Y', 75),
('A', 'Z', 80),
('B', 'X', 90),
('B', 'Y', 91),
('B', 'Z', 75);  

SELECT S1.SNAME ,SUM(DISTINCT S1.MARKS) AS MARKS 
FROM StudentMarks AS S1
WHERE (
SELECT COUNT(DISTINCT S2.MARKS)
FROM StudentMarks AS S2
WHERE S2.MARKS>S1.MARKS AND S2.SNAME=S1.SNAME
)<=1
GROUP BY S1.SNAME