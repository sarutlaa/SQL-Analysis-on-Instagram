CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE
);

CREATE TABLE Posts (
    post_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    caption TEXT,
    image_url VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Comments (
    comment_id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Likes (
    like_id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Followers (
    follower_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    follower_user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (follower_user_id) REFERENCES Users(user_id)
);

-- Inserting into Users table
INSERT INTO Users (name, email, phone_number)
VALUES
    ('John Smith', 'johnsmith@gmail.com', '1234567890'),
    ('Jane Doe', 'janedoe@yahoo.com', '0987654321'),
    ('Bob Johnson', 'bjohnson@gmail.com', '1112223333'),
    ('Alice Brown', 'abrown@yahoo.com', NULL),
    ('Mike Davis', 'mdavis@gmail.com', '5556667777');

-- Inserting into Posts table
INSERT INTO Posts (user_id, caption, image_url)
VALUES
    (1, 'Beautiful sunset', '<https://www.example.com/sunset.jpg>'),
    (2, 'My new puppy', '<https://www.example.com/puppy.jpg>'),
    (3, 'Delicious pizza', '<https://www.example.com/pizza.jpg>'),
    (4, 'Throwback to my vacation', '<https://www.example.com/vacation.jpg>'),
    (5, 'Amazing concert', '<https://www.example.com/concert.jpg>');

-- Inserting into Comments table
INSERT INTO Comments (post_id, user_id, comment_text)
VALUES
    (1, 2, 'Wow! Stunning.'),
    (1, 3, 'Beautiful colors.'),
    (2, 1, 'What a cutie!'),
    (2, 4, 'Aww, I want one.'),
    (3, 5, 'Yum!'),
    (4, 1, 'Looks like an awesome trip.'),
    (5, 3, 'Wish I was there!');

-- Inserting into Likes table
INSERT INTO Likes (post_id, user_id)
VALUES
    (1, 2),
    (1, 4),
    (2, 1),
    (2, 3),
    (3, 5),
    (4, 1),
    (4, 2),
    (4, 3),
    (5, 4),
    (5, 5);

-- Inserting into Followers table
INSERT INTO Followers (user_id, follower_user_id)
VALUES
    (1, 2),
    (2, 1),
    (1, 3),
    (3, 1),
    (1, 4),
    (4, 1),
    (1, 5),
    (5, 1);
	
-- update caption in posts table
select * from posts;

update posts
set caption = ' Best Pizza Ever'
where post_id = 3;

select * from posts where user_id = 2;

-- Selecting all the posts and ordering them by created_at in descending order
SELECT *
FROM Posts
ORDER BY created_at DESC;

-- Counting the number of likes for each post and showing only the posts with more than 1 likes
select posts.post_id, count(likes.like_id) as num_likes from posts
left join likes on posts.post_id = likes.post_id
group by posts.post_id
having count(likes.like_id) > 1
order by num_likes;


-- Finding the total number of likes for all posts
select sum(num_likes) as total_likes
from (select count(likes.like_id) as num_likes
	 from posts
	 left join likes on posts.post_id = likes.like_id
	 group by posts.post_id) AS likes_by_post;


-- Finding all the users who have commented on post_id 1
SELECT name
FROM Users
WHERE user_id IN (
    SELECT user_id
    FROM Comments
    WHERE post_id = 1
);

-- Ranking the posts based on the number of likes
SELECT post_id, num_likes, RANK() OVER (ORDER BY num_likes DESC) AS rank
FROM (
    SELECT Posts.post_id, COUNT(Likes.like_id) AS num_likes
    FROM Posts
    LEFT JOIN Likes ON Posts.post_id = Likes.post_id
    GROUP BY Posts.post_id
) AS likes_by_post;

SELECT post_id, num_likes, DENSE_RANK() OVER (ORDER BY num_likes DESC) AS rank
FROM (
    SELECT Posts.post_id, COUNT(Likes.like_id) AS num_likes
    FROM Posts
    LEFT JOIN Likes ON Posts.post_id = Likes.post_id
    GROUP BY Posts.post_id
) AS likes_by_post;


-- Finding all the posts and their comments using a Common Table Expression (CTE)
WITH post_comments AS (
    SELECT Posts.post_id, Posts.caption, Comments.comment_text
    FROM Posts
    LEFT JOIN Comments ON Posts.post_id = Comments.post_id
)
SELECT *
FROM post_comments;

-- Categorizing the posts based on the number of likes
SELECT
    post_id,
    CASE
        WHEN num_likes = 0 THEN 'No likes'
        WHEN num_likes < 2 THEN 'Less likes'
        WHEN num_likes > 2 THEN 'Some likes'
        ELSE 'Lots of likes'
    END AS like_category
FROM (
    SELECT Posts.post_id, COUNT(Likes.like_id) AS num_likes
    FROM Posts
    LEFT JOIN Likes ON Posts.post_id = Likes.post_id
    GROUP BY Posts.post_id
) AS likes_by_post;


-- Finding all the posts created in the last month
SELECT *
FROM Posts
WHERE created_at >= CAST(DATE_TRUNC('month', CURRENT_TIMESTAMP - INTERVAL '1 month') AS DATE);

-- Which users have liked post_id 2?
-- select * from users;
-- select * from likes;

select u.name from users u
left join likes l on u.user_id = l.user_id
where l.post_id = 2;

-- Which posts have no comments?
select * from posts p
left join comments c on p.post_id = c.post_id
where c.comment_id is null;

SELECT Posts.caption
FROM Posts
LEFT JOIN Comments ON Posts.post_id = Comments.post_id
WHERE Comments.comment_id IS NULL;

-- Which posts were created by users who have no followers?
select * from posts p
left join followers f on
p.user_id = f.user_id 
where follower_id is null;

-- How many likes does each post have?
select p.caption, count(l.like_id) as like_count from likes l
left join posts p on p.post_id = l.post_id
group by p.caption
order by 1;

-- What is the average number of likes per post?
with likes_data as (
select p.caption, count(l.like_id) as like_count from likes l
left join posts p on p.post_id = l.post_id
group by p.caption
order by 1)
select avg(like_count) from likes_data;


-- Which user has the most followers?
with users_data as (select u.name, count(f.follower_id) as total_followers from users u
				   left join followers f
				   on u.user_id = f.user_id
				   group by u.name
				   )
select name, max(total_followers) as max_followers from users_data 
group by name
order by max_followers desc
limit 1;

-- Rank the users by the number of posts they have created.
SELECT name, num_posts, RANK() OVER (ORDER BY num_posts DESC) AS rank
FROM (
    SELECT Users.name, COUNT(Posts.post_id) AS num_posts
    FROM Users
    LEFT JOIN Posts ON Users.user_id = Posts.user_id
    GROUP BY Users.user_id
) AS posts_by_user;

-- Rank the posts based on the number of likes.
select post_id, like_count, rank() over (order by like_count desc) as rank
from (
select p.post_id, count(l.like_id) as like_count from likes l
right join posts p on p.post_id = l.post_id
group by p.post_id
order by 1 ) as likes_by_post;

-- Find the cumulative number of likes for each post.
select post_id, like_count, sum(like_count) over (order by created_at) as cummulative_likes
from (
select p.post_id, count(l.like_id) as like_count, p.created_at  from likes l
right join posts p on p.post_id = l.post_id
group by p.post_id
order by 1 ) as likes_by_post;

-- Find all the comments and their users using a Common Table Expression (CTE)
with users_comments as (
select u.name, c.comment_text, c.comment_id
from users u
left join comments c on u.user_id = c.user_id
order by 3
)
select * from users_comments;


-- Find all the followers and their follower users using a CTE.
WITH follower_users AS (
    SELECT Users.name AS follower, follower_users.name AS user_followed
    FROM Users
    JOIN Followers ON Users.user_id = Followers.follower_user_id
    JOIN Users AS follower_users ON Followers.user_id = follower_users.user_id
)
SELECT *
FROM follower_users;

-- Find all the posts and their comments using a CTE.
WITH post_comments AS (
    SELECT Posts.caption, Comments.comment_text
    FROM Posts
    LEFT JOIN Comments ON Posts.post_id = Comments.post_id
)
SELECT *
FROM post_comments;


-- Categorize the users based on the number of comments they have made.
SELECT
    Users.name,
    CASE
        WHEN num_comments = 0 THEN 'No comments'
        WHEN num_comments < 5 THEN 'Few comments'
        WHEN num_comments < 10 THEN 'Some comments'
        ELSE 'Lots of comments'
    END AS comment_category
FROM Users
LEFT JOIN (
    SELECT user_id, COUNT(comment_id) AS num_comments
    FROM Comments
    GROUP BY user_id
) AS comments_by_user ON Users.user_id = comments_by_user.user_id;


-- Categorize the posts based on their age.
SELECT
    post_id,
    CASE
        WHEN age_in_days < 7 THEN 'New post'
        WHEN age_in_days < 30 THEN 'Recent post'
        ELSE 'Old post'
    END AS age_category
FROM (
    SELECT post_id, CURRENT_DATE - created_at::DATE AS age_in_days
    FROM Posts
) AS post_ages;





