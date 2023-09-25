
/*

Data Analysis Stack Exchange in SQL Queries

*/



SELECT *
FROM posts


--------------------------------------------------------------------------------------------------------------------------

--Number of posts is created for each year

SELECT YEAR(CreationDate) as CreationYear, count(*) AS NumPostPerYear
FROM posts
GROUP BY YEAR(CreationDate)
ORDER BY CreationYear


--------------------------------------------------------------------------------------------------------------------------

--Number of votes were made in each day of the week (Sunday, Monday, Tuesday, etc.) 

SELECT *
FROM Votes

SELECT DATENAME(weekday,CreationDate) AS CreationDateName, count(*) NumPostPerWeekDay
FROM Votes
GROUP BY DATENAME(weekday,CreationDate)
ORDER BY 
	CASE DATENAME(weekday,CreationDate)
		WHEN 'Monday' THEN 1
		WHEN 'Tuesday' THEN 2
		WHEN 'Wednesday' THEN 3
		WHEN 'Thursday' THEN 4
		WHEN 'Friday' THEN 5
		WHEN 'Saturday' THEN 6
		WHEN 'Sunday' THEN 7
	END;


--------------------------------------------------------------------------------------------------------------------------

--List of all comments created on September 19th, 2012

SELECT *
FROM Comments


SELECT Text, CONVERT(DATE,CreationDate) AS OnlyCreationDate
FROM Comments
WHERE CONVERT(DATE,CreationDate) = '2012-12-19'

--------------------------------------------------------------------------------------------------------------------------

--List of all users under the age of 33, living in London

SELECT *
FROM Users


SELECT *
FROM Users
WHERE Age < 33 AND Location LIKE '%London%'


--------------------------------------------------------------------------------------------------------------------------

--Number of votes for each post title

SELECT *
FROM posts
WHERE Id=8

SELECT *
FROM Votes
WHERE PostId = 8

SELECT p.Title,p.Id, count(p.Title) AS NumVotesPerPost
FROM Votes AS v
JOIN posts AS p
ON v.PostId = p.Id
GROUP BY p.Title,p.Id


--------------------------------------------------------------------------------------------------------------------------

--Posts with comments created by users living in the same location as the post creator

SELECT p.Id as post_Id, p.OwnerUserId as postUserId, p.Title, c.PostId, c.UserId as commnetuserId, 
user_post.Location as PostuserLocation, users_comment.Location as CommentUserLocation
FROM posts p
JOIN Users user_post
ON user_post.Id = p.OwnerUserId
JOIN Comments c
ON c.PostId = p.Id
JOIN Users users_comment
ON c.UserId = users_comment.Id
WHERE user_post.Location = users_comment.Location
ORDER By post_Id


--------------------------------------------------------------------------------------------------------------------------

--Number of users who have never voted 

WITH CTE_usersNoVoted AS (
SELECT Id
FROM Users 
EXCEPT 
SELECT UserId
FROM Votes
)

SELECT count(*)
FROM CTE_usersNoVoted


--------------------------------------------------------------------------------------------------------------------------

--Posts have the highest amount of comments

with cte_ranking_comment_post As (
SELECT p.Id as postId, p.Title,count(*) as NumCommentPerPost,
DENSE_RANK () OVER (ORDER BY count(*) DESC) as rank_NumCommentPerPost
FROM posts p
JOIN Comments c
ON p.Id = c.PostId
GROUP BY p.Id,p.Title
)

SELECT postId, Title
FROM cte_ranking_comment_post
WHERE rank_NumCommentPerPost=1


--------------------------------------------------------------------------------------------------------------------------

--For each post, Number of votes come from users living in Canada, and their percentage of the total number of votes


SELECT p.Id,p.title, count(*) as TotalNumVotes, 
SUM(Case when u.Location LIKE '%Canada%' THEN 1 ELSE 0 END) AS NumVotesCanada,
CAST(SUM(Case when u.Location LIKE '%Canada%' THEN 1 ELSE 0 END) As float)/CAST(count(*) AS float) AS percentageVoteCanada
FROM posts p
JOIN Votes v
ON p.Id = v.PostId
JOIN Users u
ON u.Id = v.UserId
GROUP BY p.Id,p.title


--------------------------------------------------------------------------------------------------------------------------

--Average number of hours takes to the first comment to be posted after a creation of a new post


WITH CTE_firstCommentPerPost as(
SELECT p.Id,p.Title, p.CreationDate as PostCreationDate, min(c.CreationDate) as FirstCommentCreationDate
FROM posts p
JOIN Comments c
ON p.Id = c.PostId
GROUP BY p.Id,p.Title, p.CreationDate 
)

SELECT AVG(DATEDIFF(hour, PostCreationDate, FirstCommentCreationDate)) As TimeInterval_postFirstCommnet_perhouhour
FROM CTE_firstCommentPerPost


--------------------------------------------------------------------------------------------------------------------------

--The most common post tag


--solution1

WITH "CTE-TAGS-SEP" (Tags) AS
(
    SELECT CAST(Tags AS VARCHAR(MAX)) 
    FROM Posts
    UNION ALL
    SELECT STUFF(Tags, 1, CHARINDEX('><' , Tags), '') 
    FROM "CTE-TAGS-SEP"
    WHERE Tags  LIKE '%><%'
), "CTE-TAGS-COUNTER" AS 
(   
    SELECT CASE WHEN Tags LIKE '%><%' THEN LEFT(Tags, CHARINDEX('><' , Tags)) 
                ELSE Tags 
            END AS 'Tags'
    FROM "CTE-TAGS-SEP"
)

SELECT TOP 1 COUNT(*), Tags
FROM "CTE-TAGS-COUNTER"
GROUP BY Tags 
ORDER BY COUNT(*) DESC 

--solution2 


SELECT REPLACE(REPLACE(REPLACE(Tags, '><', ','), '<',''),'>','') 'TAGS' INTO #TABI2
FROM posts
SELECT VALUE, COUNT(*)
FROM #TABI2
CROSS APPLY string_split(TAGS, ',')
GROUP BY VALUE
ORDER BY COUNT(*) DESC


--------------------------------------------------------------------------------------------------------------------------

--Creating a pivot table that displays how many posts were created for each year (Y axis) and each month (X axis)


SELECT *
FROM (
	SELECT Id, YEAR(CreationDate) AS 'Year', DATENAME(MONTH,CreationDate) AS 'Month'
	FROM posts
) AS SourceTable
PIVOT (
	COUNT(Id)
	FOR month IN ([January],[February],[March],[April],[May],[June],[July],[August],[September],[October],[November],[December])	
) AS PVT
ORDER BY Year







