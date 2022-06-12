/*
Change collate in 2 plases for succeses install

SELECT       sso.[Option], sso.[Value]
				FROM         #SQLsharpOptions sso
				INNER JOIN   sys.assemblies sa
						--ON sa.[name] = sso.[Option] --COLLATE database_default
						--DON change COLLATE for install
						ON sa.[name] = sso.[Option] COLLATE Latin1_General_100_CI_AS
				WHERE        sso.[Option] LIKE N'SQL#%'
				AND          sso.[Option] <> N'SQL#' -- Do NOT reset main SQL# Assembly to EXTERNAL_ACCESS or UNSAFE
				AND          sso.[Value] <> 'SAFE'
				ORDER BY     sa.[name];

SELECT       sa.[name], CASE sa.[permission_set]
							WHEN 1 THEN 'SAFE' -- SAFE_ACCESS
							WHEN 3 THEN 'UNSAFE' -- UNSAFE_ACCESS
							ELSE sa.[permission_set_desc] -- EXTERNAL_ACCESS (2)
						END
		FROM         sys.assemblies sa
		LEFT JOIN    #SQLsharpOptions sso
				--DON change COLLATE for install
				ON sso.[Option] = sa.[name] collate Cyrillic_General_CI_AS
		WHERE        sa.[name] LIKE N'SQL#%'
		AND          sso.[Value] IS NULL
		--AND		sa.permission_set <> 1 -- SAFE_ACCESS
		;*/
USE [KPK_DB1]; 
select [SQL#].[Date_Format]('20220612','dd.MM.yyyy','')
select [SQL#].[Date_Format]('20220612','D','uk')