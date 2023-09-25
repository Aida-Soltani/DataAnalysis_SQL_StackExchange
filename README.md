# DataAnalysis_StackExchange

Stack Exchange is a network of websites that enables information sharing and learning among various populations.
One of these websites, Movies & TV Stack Exchange, is dedicated solely to questions and answers about films and television shows. 



- General Description


This database consists of 4 tables

Posts – Each post can have different comments, each post can be voted by different users (in order to improve its ranking)
Votes – Each vote consists of a voting ID, user number (FK), post number (FK), and a date of creation
Comments – The details regarding the various posts comments
Users – The details of the users who commented / wrote a post / voted
