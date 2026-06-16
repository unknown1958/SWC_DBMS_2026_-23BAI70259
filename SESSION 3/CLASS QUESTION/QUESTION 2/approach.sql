CREATE TABLE test_data (
    col1 INT,
    col2 VARCHAR(50)
);

INSERT INTO test_data (col1, col2) VALUES
(1, 'A,B,C'),
(2, 'A,

)


SELECT col1, LENGTH(COL2)-LENGTH(REPLACE(COL2,',',''))+1 AS COL2
FROM TEST_DATA