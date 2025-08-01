-- Fix the users table id column type to match JPA entity (BIGINT)
-- This migration alters the id column from INTEGER (SERIAL) to BIGINT

ALTER TABLE users 
ALTER COLUMN id TYPE BIGINT;

-- Update the sequence to use BIGINT
ALTER SEQUENCE users_id_seq AS BIGINT;

-- Ensure the sequence is owned by the table
ALTER SEQUENCE users_id_seq OWNED BY users.id;