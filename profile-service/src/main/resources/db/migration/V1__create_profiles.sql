CREATE TABLE profiles (
    id UUID PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    headline VARCHAR(160) NOT NULL,
    summary VARCHAR(2000),
    location VARCHAR(120)
);
