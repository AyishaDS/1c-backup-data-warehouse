
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [DIM].[Date](
	[date_key] [int] NOT NULL,
	[full_date] [date] NOT NULL,
	[day] [tinyint] NOT NULL,
	[month] [tinyint] NOT NULL,
	[month_name] [nvarchar](20) NOT NULL,
	[year] [smallint] NOT NULL,
	[quarter] [tinyint] NOT NULL,
	[week_of_year] [tinyint] NOT NULL,
	[iso_year] [smallint] NOT NULL,
	[weekday_num] [tinyint] NOT NULL,
	[weekday_name] [nvarchar](20) NOT NULL,
	[is_weekend] [bit] NOT NULL,
 CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED 
(
	[date_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO