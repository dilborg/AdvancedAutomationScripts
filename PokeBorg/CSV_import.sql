DROP TABLE drones;
CREATE TABLE drones (
	user varchar(255) not null, 
	pass varchar(255) not null);
.separator :
.import 10.csv drones
SELECT * FROM drones;