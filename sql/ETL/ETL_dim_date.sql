
TRUNCATE TABLE DIM.Date; -- no FK references DIM.Date
GO

SET LANGUAGE us_english;   

DECLARE @start       DATE    = '2000-01-01';
DECLARE @end         DATE    = '2070-12-31';
DECLARE @d           DATE    = @start;
DECLARE @weekday_num TINYINT;
DECLARE @iso_week    TINYINT;

BEGIN TRAN;

WHILE @d <= @end
BEGIN
    
    SET @weekday_num =
        CASE DATEPART(WEEKDAY, @d)
            WHEN 1 THEN 7
            ELSE DATEPART(WEEKDAY, @d) - 1
        END;

    SET @iso_week = DATEPART(ISO_WEEK, @d);

    INSERT INTO DIM.Date (
        date_key, full_date, day, month, month_name,
        quarter, year, week_of_year, iso_year,
        weekday_num, weekday_name, is_weekend
    )
    VALUES (
        CONVERT(INT, CONVERT(CHAR(8), @d, 112)),
        @d,
        DAY(@d),
        MONTH(@d),
        DATENAME(MONTH, @d),
        DATEPART(QUARTER, @d),
        YEAR(@d),
        @iso_week,
        YEAR(DATEADD(DAY, 26 - @iso_week, @d)),
        @weekday_num,
        DATENAME(WEEKDAY, @d),
        CASE WHEN @weekday_num IN (6, 7) THEN 1 ELSE 0 END
    );

    SET @d = DATEADD(DAY, 1, @d);
END;

COMMIT;
GO

