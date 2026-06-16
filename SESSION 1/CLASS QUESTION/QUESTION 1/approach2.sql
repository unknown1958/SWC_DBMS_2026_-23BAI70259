CREATE TABLE tbl_happiness (
    sno INT,
    rankings INT,
    country VARCHAR(50)
);

-- Insert Data
INSERT INTO tbl_happiness (sno, rankings, country) VALUES
(1, 1, 'Finland'),
(2, 2, 'Denmark'),
(3, 3, 'Iceland'),
(4, 4, 'Israel'),
(5, 5, 'Netherlands'),
(6, 6, 'Sweden'),
(7, 7, 'Norway'),
(8, 126, 'India'),
(9, 128, 'Sri Lanka');

-- Approach 2
-- (i
SELECT RANKINGS,COUNTRY
FROM tbl_happiness 
ORDER BY CASE WHEN COUNTRY ='India' THEN 1 
      WHEN COUNTRY ='Sri Lanka' THEN 2
	  	ELSE 3
		  END ,rankings


-- (ii)


SELECT RANKINGS,COUNTRY
FROM tbl_happiness 
ORDER BY CASE WHEN COUNTRY ='India' THEN 1 
      WHEN COUNTRY ='Sri Lanka' THEN 2
	  	ELSE 3
		  END ,rankings desc 