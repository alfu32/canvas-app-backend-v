CREATE DATABASE `geodb` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */

CREATE TABLE `BOXES` (
                         `id` varchar(40) NOT NULL,
                         `ent_type` varchar(40) DEFAULT NULL,
                         `json` varchar(4000) DEFAULT NULL,
                         `x0` double DEFAULT NULL,
                         `y0` double DEFAULT NULL,
                         `x1` double DEFAULT NULL,
                         `y1` double DEFAULT NULL,
                         `visible_size` double DEFAULT NULL,
                         PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `METADATA` (
                            `id` varchar(40) NOT NULL,
                            `json` varchar(4000) DEFAULT NULL,
                            PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `TECHNOLANG` (
                              `technoid` varchar(40) DEFAULT NULL,
                              `langid` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE DEFINER=`admin`@`localhost` FUNCTION `box_contains_point`(px decimal(15),py decimal(15),
                                                                 bx0 decimal(15), by0 decimal(15), bx1 decimal(15), by1 decimal(15)
) RETURNS tinyint(1)
BEGIN
    return px>=bx0 and px<=bx1 AND py>=by0 and py<=by1;
END;


CREATE DEFINER=`admin`@`localhost` FUNCTION `box_intersects_box`(ax0 decimal(15), ay0 decimal(15), ax1 decimal(15), ay1 decimal(15),
	bx0 decimal(15), by0 decimal(15), bx1 decimal(15), by1 decimal(15)
) RETURNS tinyint(1)
BEGIN
    return box_contains_point(ax0,ay0, bx0,by0,bx1,by1)
        OR box_contains_point(ax0,ay1, bx0,by0,bx1,by1)
        OR box_contains_point(ax1,ay1, bx0,by0,bx1,by1)
        OR box_contains_point(ax1,ay0, bx0,by0,bx1,by1)
        OR box_contains_point(bx0,by0, ax0,ay0,ax1,ay1)
        OR box_contains_point(bx0,by1, ax0,ay0,ax1,ay1)
        OR box_contains_point(bx1,by1, ax0,ay0,ax1,ay1)
        OR box_contains_point(bx1,by0, ax0,ay0,ax1,ay1)
        or (
                       ax0<=bx0 AND ax1 >=bx1 AND (
                               ay0 >= by0 AND ay0<=by1
                       or
                               ay1 >= by0 AND ay1<=by1
                   )
               )
        or (
                       ay0<=by0 AND ay1 >=by1 AND (
                               ax0 >= bx0 AND ax0<=bx1
                       or
                               ax1 >= bx0 AND ax1<=bx1
                   )
               );
END;


CREATE DEFINER=`admin`@`localhost` FUNCTION `get_box`(ax NUMERIC(15),
	ay NUMERIC(15),
	szx NUMERIC(15),
	szy NUMERIC(15)
) RETURNS geometry
BEGIN
    return ST_POLYGONFROMTEXT(CONCAT(
            'POLYGON((',
            ax,' ',ay,',',
            ax+szx,' ',ay,',',
            ax+szx,' ',ay+szy,',',
            ax,' ',ay+szy,',',
            ax,' ',ay,'',
            '))'));
END;


CREATE DEFINER=`admin`@`localhost` FUNCTION `get_box_from_json`(json VARCHAR(4000)) RETURNS geometry
BEGIN
    DECLARE ax NUMERIC(15);
    DECLARE ay NUMERIC(15);
    DECLARE szx NUMERIC(15);
    DECLARE szy NUMERIC(15);
    DECLARE boxtype VARCHAR(50);
    SELECT JSON_VALUE(json,'$.ent_type') INTO boxtype;
    SELECT JSON_VALUE(json,'$.anchor.x') INTO ax;
    SELECT JSON_VALUE(json,'$.anchor.y') INTO ay;
    SELECT JSON_VALUE(json,'$.size.x') INTO szx;
    SELECT JSON_VALUE(json,'$.size.y') INTO szy;
    return get_box(ax,ay,szx,szy);
END;


CREATE DEFINER=`admin`@`localhost` PROCEDURE `store_box`(
	ent_id VARCHAR(40),
	ent_ent_type VARCHAR(40),
	ent_json VARCHAR(4000),
	ent_x0 DOUBLE,
	ent_y0 DOUBLE,
	ent_x1 DOUBLE,
	ent_y1 DOUBLE,
	ent_visible_size DOUBLE
)
BEGIN
    DELETE FROM BOXES WHERE ID=ent_id;
    COMMIT;
    INSERT INTO BOXES(id,ent_type,json,x0,y0,x1,y1,visible_size)
    VALUES (ent_id,ent_ent_type,ent_json,ent_x0,ent_y0,ent_x1,ent_y1,ent_visible_size);
    COMMIT;
end;



