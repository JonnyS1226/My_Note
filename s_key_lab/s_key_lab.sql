/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50725
Source Host           : localhost:3306
Source Database       : s_key_lab

Target Server Type    : MYSQL
Target Server Version : 50725
File Encoding         : 65001

Date: 2020-06-22 11:09:29
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `users`
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `current_otp` varchar(255) NOT NULL,
  `total_n` int(11) NOT NULL,
  `current_index` int(11) NOT NULL,
  `salt` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('4', 'shaojiayi', 'aed5b60c03bf1dea5e6f9a01855cfa45', '10', '10', 'NuB4d');
