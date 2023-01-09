CREATE TABLE t_User
(
    id TEXT NOT NULL PRIMARY KEY,
    [name] TEXT,
    email TEXT,
    birthDate TEXT NOT NULL,
    avatar TEXT,
    subscriberCount INT NOT NULL,
    subscriptionCount INT NOT NULL
);
CREATE TABLE t_Post
(
    id TEXT NOT NULL PRIMARY KEY,
    [text] TEXT,
    authorId TEXT NOT NULL, 
    likes INT NOT NULL,
    comments INT NOT NULL,
    CONSTRAINT author_fk FOREIGN KEY(authorId) REFERENCES t_User(id)
);
CREATE TABLE t_PostContent
(
    id TEXT NOT NULL PRIMARY KEY,
    [name] TEXT,
    mimeType TEXT,
    postId TEXT NOT NULL, 
    contentLink TEXT,
    CONSTRAINT post_fk FOREIGN KEY(postId) REFERENCES t_Post(id)
);