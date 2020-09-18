DROP TABLE IF EXISTS `validations_pages`;

CREATE TABLE `validations_pages`
(
id          INT(11) AUTO_INCREMENT,
route       VARCHAR(255) NOT NULL,
specs       VARCHAR(32) DEFAULT NULL,
created_at  VARCHAR(10) DEFAULT NULL,
updated_at  VARCHAR(10) DEFAULT NULL,
PRIMARY KEY (id)
);
