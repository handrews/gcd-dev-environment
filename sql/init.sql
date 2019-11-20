
CREATE USER IF NOT EXISTS 'gcdonline'@'localhost';
DROP DATABASE IF EXISTS gcdonline;
CREATE DATABASE gcdonline DEFAULT CHARACTER SET 'utf8';

GRANT ALL ON gcdonline.* TO 'gcdonline'@'localhost';
