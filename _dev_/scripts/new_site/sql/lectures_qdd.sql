USE icare

ALTER TABLE `lectures_qdd` ADD COLUMN `cote_comments` TINYINT DEFAULT NULL AFTER `cotes`;
ALTER TABLE `lectures_qdd` ADD COLUMN `cote_original` TINYINT DEFAULT NULL AFTER `cotes`;

UPDATE `lectures_qdd` SET `cote_comments` = CONVERT(SUBSTRING(cotes,1,1),UNSIGNED) ;
UPDATE `lectures_qdd` SET `cote_original` = CONVERT(SUBSTRING(cotes,2,1),UNSIGNED) ;

UPDATE `lectures_qdd` SET `cote_original` = NULL WHERE `cote_original` = 0;
UPDATE `lectures_qdd` SET `cote_comments` = NULL WHERE `cote_comments` = 0;

ALTER TABLE `lectures_qdd` DROP COLUMN `cotes`;
