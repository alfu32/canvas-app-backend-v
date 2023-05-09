CREATE DATABASE `geodb` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;


/* TABLES */

CREATE TABLE `BOXES` (
                         `id` varchar(40) NOT NULL,
                         `ent_type` varchar(40) DEFAULT NULL,
                         `json` varchar(4000) DEFAULT NULL,
                         `x0` double DEFAULT NULL,
                         `y0` double DEFAULT NULL,
                         `x1` double DEFAULT NULL,
                         `y1` double DEFAULT NULL,
                         `visible_size` double DEFAULT NULL,
                         `dt_created` timestamp NULL DEFAULT current_timestamp(),
                         `dt_updated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
                         `notes` varchar(40) DEFAULT NULL,
                         PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci

CREATE TABLE `METADATA` (
                            `id` varchar(40) NOT NULL,
                            `json` varchar(4000) DEFAULT NULL,
                            `dt_created` timestamp NOT NULL DEFAULT current_timestamp(),
                            `dt_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
                            `notes` varchar(40) DEFAULT NULL,
                            PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci

CREATE TABLE `TECHNOLANG` (
                              `technoid` varchar(40) DEFAULT NULL,
                              `langid` varchar(40) DEFAULT NULL,
                              `compiler_id` varchar(40) DEFAULT NULL,
                              `dt_created` timestamp NOT NULL DEFAULT current_timestamp(),
                              `dt_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
                              `notes` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci

CREATE TABLE `test` (
                        `id` varchar(255) NOT NULL,
                        `data` varchar(255) DEFAULT NULL,
                        PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci

/* VIEWS */

CREATE OR REPLACE VIEW V_PARENT AS
SELECT
    ID as id,
    JSON_VALUE(json,'$.parent.ref') as parent_id
FROM BOXES
WHERE ent_type='Drawable';

CREATE OR REPLACE VIEW geodb.V_HIERARCHY as
WITH RECURSIVE hierarchy AS (
    SELECT id,
           CAST(id AS VARCHAR(4000)) AS path,
           CAST(id AS VARCHAR(4000)) AS path_reversed
    FROM V_PARENT
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        c.id,
        CONCAT(c.id,',',p.path ) path,
        CONCAT(p.path_reversed,',',c.id ) path_reversed
    FROM V_PARENT c
             JOIN hierarchy p ON c.parent_id = p.id
)
SELECT id,path,path_reversed
FROM hierarchy
UNION ALL
SELECT id,'' as path,'' as path_reversed
FROM V_PARENT
WHERE V_PARENT.parent_id IS null;

CREATE OR REPLACE VIEW  geodb.V_LINKS as
select `geodb`.`BOXES`.`id` AS `ID`,
       json_value(`geodb`.`BOXES`.`json`,'$.source.ref') AS `source`,
       json_value(`geodb`.`BOXES`.`json`,'$.destination.ref') AS `destination`
from `geodb`.`BOXES` where `geodb`.`BOXES`.`ent_type` = 'Link';

CREATE OR REPLACE VIEW V_PARENTCHILD AS
SELECT
    BOXES.ID as id,
    JSON_VALUE(json,'$.parent.ref') as parent_id,
    CHILDREN.child as child_id
FROM BOXES
         LEFT OUTER JOIN (
      SELECT
          bx0.ID,
          TT.ref as child
      FROM BOXES bx0,
      JSON_TABLE(bx0.json,
        "$.children[*]"
         COLUMNS(
           rowid FOR ORDINALITY,
           ref VARCHAR(40) PATH "$.ref" DEFAULT 'a' ON ERROR DEFAULT 'b' ON EMPTY
         )
        ) TT
        WHERE bx0.ent_type='Drawable') CHILDREN ON CHILDREN.ID=BOXES.ID
WHERE ent_type='Drawable';

/* FUNCTIONS */

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


create definer = admin@localhost procedure store_box(IN ent_id varchar(40), IN ent_ent_type varchar(40), IN ent_json varchar(4000), IN ent_x0 double, IN ent_y0 double, IN ent_x1 double, IN ent_y1 double, IN ent_visible_size double)
BEGIN
    /*DELETE FROM BOXES WHERE ID=ent_id;
    COMMIT;*/
    INSERT INTO BOXES(id,ent_type,json,x0,y0,x1,y1,visible_size)
    VALUES (ent_id,ent_ent_type,ent_json,ent_x0,ent_y0,ent_x1,ent_y1,ent_visible_size)
    ON DUPLICATE KEY UPDATE
                         ent_id=VALUES(ent_id),
                         ent_ent_type=VALUES(ent_ent_type),
                         ent_json=VALUES(ent_json),
                         ent_x0=VALUES(ent_x0),
                         ent_y0=VALUES(ent_y0),
                         ent_x1=VALUES(ent_x1),
                         ent_y1=VALUES(ent_y1),
                         ent_visible_size=VALUES(ent_visible_size)
    ;
    COMMIT;
end;



