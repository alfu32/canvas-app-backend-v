CREATE DATABASE IF NOT EXISTS `geodb` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

CREATE USER 'admin' identified by '1234' WITH GRANT OPTION;
GRANT ALL ON 'admin' identified by '1234' WITH GRANT OPTION;
CREATE USER 'su' identified by '1234' WITH GRANT OPTION;
GRANT ALL ON 'su' identified by '1234' WITH GRANT OPTION;
FLUSH PRIVILEGES;


/* TABLES */

create or replace table BOXES
(
    id           varchar(40)                           not null
    primary key,
    ent_type     varchar(40)                           null,
    json         varchar(4000)                         null,
    x0           double                                null,
    y0           double                                null,
    x1           double                                null,
    y1           double                                null,
    visible_size double                                null,
    dt_created   timestamp default current_timestamp() null,
    dt_updated   timestamp default current_timestamp() null on update current_timestamp(),
    dt_deleted   timestamp default null,
    notes        varchar(40)                           null
);
alter table BOXES
    modify json LONGTEXT null;

create or replace table METADATA
(
    id         varchar(40)                           not null
    primary key,
    json       varchar(4000)                         null,
    dt_created timestamp default current_timestamp() not null,
    dt_updated timestamp default current_timestamp() not null on update current_timestamp(),
    dt_deleted   timestamp default null,
    notes      varchar(40)                           null
);
alter table METADATA
    modify json LONGTEXT null;
create or replace table TECHNOLANG
(
    technoid    varchar(40)                           null,
    langid      varchar(40)                           null,
    compiler_id varchar(40)                           null,
    dt_created  timestamp default current_timestamp() not null,
    dt_updated  timestamp default current_timestamp() not null on update current_timestamp(),
    dt_deleted   timestamp default null,
    notes       varchar(40)                           null
);

create or replace table test
(
    id   varchar(255) not null
    primary key,
    data varchar(255) null
);
-- --- VIEWS
create or replace definer = admin@`%` view V_HIERARCHY as
with recursive hierarchy as (select `V_PARENT`.`id` AS `id`,concat('"',cast(`V_PARENT`.`id` as char(4000) charset utf8mb4),'"') AS `path`,concat('"',cast(`V_PARENT`.`id` as char(4000) charset utf8mb4),'"') AS `path_reversed` from `geodb`.`V_PARENT` where `V_PARENT`.`parent_id` is null union all select `c`.`id` AS `id`,concat('"',`c`.`id`,'",',`p`.`path`) AS `path`,concat(`p`.`path_reversed`,',"',`c`.`id`,'"') AS `path_reversed` from (`geodb`.`V_PARENT` `c` join `hierarchy` `p` on(`c`.`parent_id` = `p`.`id`)))select `hierarchy`.`id` AS `id`,`hierarchy`.`path` AS `path`,`hierarchy`.`path_reversed` AS `path_reversed` from `hierarchy` union all select `V_PARENT`.`id` AS `id`,'' AS `path`,'' AS `path_reversed` from `geodb`.`V_PARENT` where `V_PARENT`.`parent_id` is null;

create or replace definer = admin@`%` view V_LINKS as
select `geodb`.`BOXES`.`id` AS `ID`,json_value(`geodb`.`BOXES`.`json`,'$.source.ref') AS `source`,json_value(`geodb`.`BOXES`.`json`,'$.destination.ref') AS `destination` from `geodb`.`BOXES` where `geodb`.`BOXES`.`ent_type` = 'Link';

create or replace definer = admin@`%` view V_PARENT as
select `geodb`.`BOXES`.`id` AS `id`,json_value(`geodb`.`BOXES`.`json`,'$.parent.ref') AS `parent_id` from `geodb`.`BOXES` where `geodb`.`BOXES`.`ent_type` = 'Drawable';

create or replace definer = admin@`%` view V_PARENTCHILD as
select `geodb`.`BOXES`.`id` AS `id`,json_value(`geodb`.`BOXES`.`json`,'$.parent.ref') AS `parent_id`,`CHILDREN`.`child` AS `child_id` from (`geodb`.`BOXES` left join (select `bx0`.`id` AS `ID`,`TT`.`ref` AS `child` from `geodb`.`BOXES` `bx0` join JSON_TABLE(`bx0`.`json`, '$.children[*]' COLUMNS (`rowid` FOR ORDINALITY, `ref` varchar(40) PATH '$.ref' DEFAULT 'b' ON EMPTY DEFAULT 'a' ON ERROR)) `TT` where `bx0`.`ent_type` = 'Drawable') `CHILDREN` on(`CHILDREN`.`ID` = `geodb`.`BOXES`.`id`)) where `geodb`.`BOXES`.`ent_type` = 'Drawable';

-- --- STORED PROCEDURES
create or replace
              definer = admin@`%` procedure V_ANCESTORS(IN e0_id varchar(40))
BEGIN
SELECT
    A.*,
    parents.*,
    bx.*
FROM (SELECT
          h.id,
          h.path,
          CONCAT('[',IFNULL(h.path,''),']') as path_json
      FROM V_HIERARCHY h
      WHERE h.id=e0_id) A
         cross join JSON_TABLE( A.path_json,
                                "$[*]"
                                COLUMNS(
                                    parent_id VARCHAR(50) PATH '$'
                                    )
    ) parents
         LEFT OUTER JOIN BOXES bx on parents.parent_id=bx.id;
END;

create or replace
              definer = admin@`%` procedure V_COMMON_ANCESTORS(IN e0_id varchar(40), IN e1_id varchar(40))
BEGIN
SELECT
    bx.id,
    bx.ent_type,
    bx.json,
    bx.x0,
    bx.y0,
    bx.x1,
    bx.y1,
    bx.visible_size,
    bx.dt_created,
    bx.dt_updated,
    bx.notes
FROM (SELECT
          h.id,
          h.path,
          CONCAT('[',IFNULL(h.path,''),']') as hhh
      FROM V_HIERARCHY h
      WHERE h.id=e0_id) A
         cross join JSON_TABLE( A.hhh,
                                "$[*]"
                                COLUMNS(
                                    id VARCHAR(50) PATH '$'
                                    )
    ) parents
         LEFT OUTER JOIN BOXES bx on PARENTS.id=bx.id;
END;

create or replace
              definer = admin@localhost function box_contains_point(px decimal(15), py decimal(15), bx0 decimal(15),
              by0 decimal(15), bx1 decimal(15),
              by1 decimal(15)) returns tinyint(1)
BEGIN
    return px>=bx0 and px<=bx1 AND py>=by0 and py<=by1;
END;

create or replace
              definer = admin@localhost function box_intersects_box(ax0 decimal(15), ay0 decimal(15), ax1 decimal(15),
              ay1 decimal(15), bx0 decimal(15), by0 decimal(15),
              bx1 decimal(15), by1 decimal(15)) returns tinyint(1)
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

create or replace
              definer = admin@localhost function get_box(ax decimal(15), ay decimal(15), szx decimal(15),
              szy decimal(15)) returns geometry
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

create or replace
              definer = admin@localhost function get_box_from_json(json varchar(4000)) returns geometry
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

create or replace
              definer = admin@localhost procedure store_box(IN ent_id varchar(40), IN ent_ent_type varchar(40),
              IN ent_json varchar(4000), IN ent_x0 double, IN ent_y0 double,
              IN ent_x1 double, IN ent_y1 double, IN ent_visible_size double)
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



-- -- DATA
-- -- TECHNOLANG
INSERT INTO geodb.TECHNOLANG (technoid, langid, compiler_id, dt_created, dt_updated, notes)
VALUES ('node', 'javascript', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('web', 'javascript', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('rhino', 'javascript', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('node', 'typescript', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('deno', 'typescript', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('vlang', 'v', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('golang', 'go', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('clang', 'c', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('kotlin-jvm', 'kotlin', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('kotlin-native', 'kotlin', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('zig', 'zig', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('rust', 'rust', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('bash', 'bash', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('text', 'txt', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('markdown', 'markdown', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('xml', 'xml', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('json', 'json', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('csv', 'csv', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('yaml', 'yaml', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null),
('toml', 'toml', null, '2023-05-09 03:56:14', '2023-05-09 03:56:14', null);



-- -- example BOXES
INSERT INTO geodb.BOXES (id, ent_type, json, x0, y0, x1, y1, visible_size, dt_created, dt_updated, notes)
VALUES ('97559640-f15b-11ed-8619-13fa779c3be4', 'Drawable', '{"id":"97559640-f15b-11ed-8619-13fa779c3be4","name":"TRANSFORM","anchor":{"x":2100,"y":550,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":null,"children":[{"ref":"9a0992b0-f15b-11ed-8619-13fa779c3be4"},{"ref":"9b2b7d71-f15b-11ed-8619-13fa779c3be4"}],"outgoingLinks":[],"incomingLinks":[],"ent_type":"Drawable"}', 2100, 550, 2300, 600, 200, '2023-05-13 06:58:40', '2023-05-13 06:58:46', null),
('9a0992b0-f15b-11ed-8619-13fa779c3be4', 'Drawable', '{"id":"9a0992b0-f15b-11ed-8619-13fa779c3be4","name":"TRANSFORM","anchor":{"x":2275,"y":600,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":{"ref":"97559640-f15b-11ed-8619-13fa779c3be4"},"children":[],"outgoingLinks":[{"ref":"f8b801c2-f15b-11ed-8a6e-3fd1cb46d16f"}],"incomingLinks":[{"ref":"f6cb7400-f15b-11ed-8a6e-3fd1cb46d16f"}],"ent_type":"Drawable"}', 2275, 600, 2475, 650, 200, '2023-05-13 06:58:44', '2023-05-13 07:01:24', null),
('9b2b7d71-f15b-11ed-8619-13fa779c3be4', 'Drawable', '{"id":"9b2b7d71-f15b-11ed-8619-13fa779c3be4","name":"TRANSFORM","anchor":{"x":2575,"y":650,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":{"ref":"97559640-f15b-11ed-8619-13fa779c3be4"},"children":[],"outgoingLinks":[{"ref":"fe05bbe2-f15b-11ed-8a6e-3fd1cb46d16f"}],"incomingLinks":[{"ref":"f8b801c2-f15b-11ed-8a6e-3fd1cb46d16f"}],"ent_type":"Drawable"}', 2575, 650, 2775, 700, 200, '2023-05-13 06:58:46', '2023-05-13 07:01:33', null),
('a5423df0-f082-11ed-a731-b353e52db9d0', 'Drawable', '{"id":"a5423df0-f082-11ed-a731-b353e52db9d0","name":"TRANSFORM","anchor":{"x":200,"y":225,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":null,"children":[{"ref":"a69b1730-f082-11ed-a731-b353e52db9d0"},{"ref":"a81d4a61-f082-11ed-a731-b353e52db9d0"},{"ref":"a8df3ad1-f082-11ed-a731-b353e52db9d0"},{"ref":"bfed2d41-f082-11ed-bad4-7be6b5b26589"}],"outgoingLinks":[],"incomingLinks":[],"ent_type":"Drawable"}', 200, 225, 400, 275, 200, '2023-05-12 05:05:42', '2023-05-12 05:06:27', null),
('a5d3f6a0-f082-11ed-a731-b353e52db9d0', 'Drawable', '{"id":"a5d3f6a0-f082-11ed-a731-b353e52db9d0","name":"TRANSFORM","anchor":{"x":2175,"y":275,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":null,"children":[],"outgoingLinks":[],"incomingLinks":[{"ref":"f1b7dcb2-f15b-11ed-8a6e-3fd1cb46d16f"},{"ref":"fe05bbe2-f15b-11ed-8a6e-3fd1cb46d16f"}],"ent_type":"Drawable"}', 2175, 275, 2375, 325, 200, '2023-05-12 05:05:43', '2023-05-13 07:02:27', null),
('a69b1730-f082-11ed-a731-b353e52db9d0', 'Drawable', '{"id":"a69b1730-f082-11ed-a731-b353e52db9d0","name":"TRANSFORM","anchor":{"x":450,"y":275,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":{"ref":"a5423df0-f082-11ed-a731-b353e52db9d0"},"children":[],"outgoingLinks":[{"ref":"eff0ff61-f15b-11ed-8a6e-3fd1cb46d16f"},{"ref":"f32e01f2-f15b-11ed-8a6e-3fd1cb46d16f"}],"incomingLinks":[{"ref":"eef672c1-f15b-11ed-8a6e-3fd1cb46d16f"}],"ent_type":"Drawable"}', 450, 275, 650, 325, 200, '2023-05-12 05:05:45', '2023-05-13 07:01:15', null),
('a81d4a61-f082-11ed-a731-b353e52db9d0', 'Drawable', '{"id":"a81d4a61-f082-11ed-a731-b353e52db9d0","name":"TRANSFORM","anchor":{"x":925,"y":275,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":{"ref":"a5423df0-f082-11ed-a731-b353e52db9d0"},"children":[],"outgoingLinks":[{"ref":"f0ef0e72-f15b-11ed-8a6e-3fd1cb46d16f"}],"incomingLinks":[{"ref":"eff0ff61-f15b-11ed-8a6e-3fd1cb46d16f"}],"ent_type":"Drawable"}', 925, 275, 1125, 325, 200, '2023-05-12 05:05:47', '2023-05-13 07:01:11', null),
('a8df3ad1-f082-11ed-a731-b353e52db9d0', 'Drawable', '{"id":"a8df3ad1-f082-11ed-a731-b353e52db9d0","name":"TRANSFORM","anchor":{"x":1500,"y":275,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":{"ref":"a5423df0-f082-11ed-a731-b353e52db9d0"},"children":[],"outgoingLinks":[{"ref":"f1b7dcb2-f15b-11ed-8a6e-3fd1cb46d16f"}],"incomingLinks":[{"ref":"f0ef0e72-f15b-11ed-8a6e-3fd1cb46d16f"},{"ref":"f5476c11-f15b-11ed-8a6e-3fd1cb46d16f"}],"ent_type":"Drawable"}', 1500, 275, 1700, 325, 200, '2023-05-12 05:05:48', '2023-05-13 07:01:19', null),
('a9df45b0-f082-11ed-a731-b353e52db9d0', 'Drawable', '{"id":"a9df45b0-f082-11ed-a731-b353e52db9d0","name":"TRANSFORM","anchor":{"x":50,"y":250,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":null,"children":[],"outgoingLinks":[{"ref":"eef672c1-f15b-11ed-8a6e-3fd1cb46d16f"}],"incomingLinks":[],"ent_type":"Drawable"}', 50, 250, 250, 300, 200, '2023-05-12 05:05:50', '2023-05-13 07:01:08', null),
('bfed2d41-f082-11ed-bad4-7be6b5b26589', 'Drawable', '{"id":"bfed2d41-f082-11ed-bad4-7be6b5b26589","name":"TRANSFORM","anchor":{"x":725,"y":400,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":{"ref":"a5423df0-f082-11ed-a731-b353e52db9d0"},"children":[{"ref":"c2936e11-f082-11ed-bad4-7be6b5b26589"},{"ref":"c3778c81-f082-11ed-bad4-7be6b5b26589"}],"outgoingLinks":[],"incomingLinks":[],"ent_type":"Drawable"}', 725, 400, 925, 450, 200, '2023-05-12 05:06:27', '2023-05-12 05:06:33', null),
('c2936e11-f082-11ed-bad4-7be6b5b26589', 'Drawable', '{"id":"c2936e11-f082-11ed-bad4-7be6b5b26589","name":"TRANSFORM","anchor":{"x":900,"y":500,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":{"ref":"bfed2d41-f082-11ed-bad4-7be6b5b26589"},"children":[],"outgoingLinks":[{"ref":"f46bb211-f15b-11ed-8a6e-3fd1cb46d16f"}],"incomingLinks":[{"ref":"f32e01f2-f15b-11ed-8a6e-3fd1cb46d16f"}],"ent_type":"Drawable"}', 900, 500, 1100, 550, 200, '2023-05-12 05:06:31', '2023-05-13 07:01:17', null),
('c3778c81-f082-11ed-bad4-7be6b5b26589', 'Drawable', '{"id":"c3778c81-f082-11ed-bad4-7be6b5b26589","name":"TRANSFORM","anchor":{"x":1225,"y":500,"z":0,"t":0,"tag":""},"size":{"x":200,"y":50,"z":0,"t":0,"tag":""},"parent":{"ref":"bfed2d41-f082-11ed-bad4-7be6b5b26589"},"children":[],"outgoingLinks":[{"ref":"f5476c11-f15b-11ed-8a6e-3fd1cb46d16f"},{"ref":"f6cb7400-f15b-11ed-8a6e-3fd1cb46d16f"}],"incomingLinks":[{"ref":"f46bb211-f15b-11ed-8a6e-3fd1cb46d16f"}],"ent_type":"Drawable"}', 1225, 500, 1425, 550, 200, '2023-05-12 05:06:33', '2023-05-13 07:01:22', null),
('eef672c1-f15b-11ed-8a6e-3fd1cb46d16f', 'Link', '{"id":"eef672c1-f15b-11ed-8a6e-3fd1cb46d16f","name":"LINK","anchor":{"x":250,"y":250,"z":0,"t":0,"tag":""},"size":{"x":-1,"y":0,"z":0,"t":0,"tag":""},"parent":null,"children":[],"source":{"ref":"a9df45b0-f082-11ed-a731-b353e52db9d0"},"destination":{"ref":"a69b1730-f082-11ed-a731-b353e52db9d0"},"path":[{"id":"a9df45b0-f082-11ed-a731-b353e52db9d0","type":"outgoing"},{"id":"a5423df0-f082-11ed-a731-b353e52db9d0","type":"incoming"},{"id":"a69b1730-f082-11ed-a731-b353e52db9d0","type":"incoming"}],"ent_type":"Link"}', 250, 250, 249, 250, 0, '2023-05-13 07:01:08', '2023-05-13 07:01:08', null),
('eff0ff61-f15b-11ed-8a6e-3fd1cb46d16f', 'Link', '{"id":"eff0ff61-f15b-11ed-8a6e-3fd1cb46d16f","name":"LINK","anchor":{"x":650,"y":275,"z":0,"t":0,"tag":""},"size":{"x":-1,"y":0,"z":0,"t":0,"tag":""},"parent":null,"children":[],"source":{"ref":"a69b1730-f082-11ed-a731-b353e52db9d0"},"destination":{"ref":"a81d4a61-f082-11ed-a731-b353e52db9d0"},"path":[{"id":"a69b1730-f082-11ed-a731-b353e52db9d0","type":"outgoing"},{"id":"a81d4a61-f082-11ed-a731-b353e52db9d0","type":"incoming"}],"ent_type":"Link"}', 650, 275, 649, 275, 0, '2023-05-13 07:01:09', '2023-05-13 07:01:09', null),
('f0ef0e72-f15b-11ed-8a6e-3fd1cb46d16f', 'Link', '{"id":"f0ef0e72-f15b-11ed-8a6e-3fd1cb46d16f","name":"LINK","anchor":{"x":1125,"y":275,"z":0,"t":0,"tag":""},"size":{"x":-1,"y":0,"z":0,"t":0,"tag":""},"parent":null,"children":[],"source":{"ref":"a81d4a61-f082-11ed-a731-b353e52db9d0"},"destination":{"ref":"a8df3ad1-f082-11ed-a731-b353e52db9d0"},"path":[{"id":"a81d4a61-f082-11ed-a731-b353e52db9d0","type":"outgoing"},{"id":"a8df3ad1-f082-11ed-a731-b353e52db9d0","type":"incoming"}],"ent_type":"Link"}', 1125, 275, 1124, 275, 0, '2023-05-13 07:01:11', '2023-05-13 07:01:11', null),
('f1b7dcb2-f15b-11ed-8a6e-3fd1cb46d16f', 'Link', '{"id":"f1b7dcb2-f15b-11ed-8a6e-3fd1cb46d16f","name":"LINK","anchor":{"x":1700,"y":275,"z":0,"t":0,"tag":""},"size":{"x":-1,"y":0,"z":0,"t":0,"tag":""},"parent":null,"children":[],"source":{"ref":"a8df3ad1-f082-11ed-a731-b353e52db9d0"},"destination":{"ref":"a5d3f6a0-f082-11ed-a731-b353e52db9d0"},"path":[{"id":"a8df3ad1-f082-11ed-a731-b353e52db9d0","type":"outgoing"},{"id":"a5423df0-f082-11ed-a731-b353e52db9d0","type":"outgoing"},{"id":"a5d3f6a0-f082-11ed-a731-b353e52db9d0","type":"incoming"}],"ent_type":"Link"}', 1700, 275, 1699, 275, 0, '2023-05-13 07:01:12', '2023-05-13 07:01:12', null),
('f32e01f2-f15b-11ed-8a6e-3fd1cb46d16f', 'Link', '{"id":"f32e01f2-f15b-11ed-8a6e-3fd1cb46d16f","name":"LINK","anchor":{"x":650,"y":275,"z":0,"t":0,"tag":""},"size":{"x":-1,"y":0,"z":0,"t":0,"tag":""},"parent":null,"children":[],"source":{"ref":"a69b1730-f082-11ed-a731-b353e52db9d0"},"destination":{"ref":"c2936e11-f082-11ed-bad4-7be6b5b26589"},"path":[{"id":"a69b1730-f082-11ed-a731-b353e52db9d0","type":"outgoing"},{"id":"bfed2d41-f082-11ed-bad4-7be6b5b26589","type":"incoming"},{"id":"c2936e11-f082-11ed-bad4-7be6b5b26589","type":"incoming"}],"ent_type":"Link"}', 650, 275, 649, 275, 0, '2023-05-13 07:01:15', '2023-05-13 07:01:15', null),
('f46bb211-f15b-11ed-8a6e-3fd1cb46d16f', 'Link', '{"id":"f46bb211-f15b-11ed-8a6e-3fd1cb46d16f","name":"LINK","anchor":{"x":1100,"y":500,"z":0,"t":0,"tag":""},"size":{"x":-1,"y":0,"z":0,"t":0,"tag":""},"parent":null,"children":[],"source":{"ref":"c2936e11-f082-11ed-bad4-7be6b5b26589"},"destination":{"ref":"c3778c81-f082-11ed-bad4-7be6b5b26589"},"path":[{"id":"c2936e11-f082-11ed-bad4-7be6b5b26589","type":"outgoing"},{"id":"c3778c81-f082-11ed-bad4-7be6b5b26589","type":"incoming"}],"ent_type":"Link"}', 1100, 500, 1099, 500, 0, '2023-05-13 07:01:17', '2023-05-13 07:01:17', null),
('f5476c11-f15b-11ed-8a6e-3fd1cb46d16f', 'Link', '{"id":"f5476c11-f15b-11ed-8a6e-3fd1cb46d16f","name":"LINK","anchor":{"x":1425,"y":500,"z":0,"t":0,"tag":""},"size":{"x":-1,"y":0,"z":0,"t":0,"tag":""},"parent":null,"children":[],"source":{"ref":"c3778c81-f082-11ed-bad4-7be6b5b26589"},"destination":{"ref":"a8df3ad1-f082-11ed-a731-b353e52db9d0"},"path":[{"id":"c3778c81-f082-11ed-bad4-7be6b5b26589","type":"outgoing"},{"id":"bfed2d41-f082-11ed-bad4-7be6b5b26589","type":"outgoing"},{"id":"a8df3ad1-f082-11ed-a731-b353e52db9d0","type":"incoming"}],"ent_type":"Link"}', 1425, 500, 1424, 500, 0, '2023-05-13 07:01:19', '2023-05-13 07:01:19', null),
('f6cb7400-f15b-11ed-8a6e-3fd1cb46d16f', 'Link', '{"id":"f6cb7400-f15b-11ed-8a6e-3fd1cb46d16f","name":"LINK","anchor":{"x":1425,"y":500,"z":0,"t":0,"tag":""},"size":{"x":-1,"y":0,"z":0,"t":0,"tag":""},"parent":null,"children":[],"source":{"ref":"c3778c81-f082-11ed-bad4-7be6b5b26589"},"destination":{"ref":"9a0992b0-f15b-11ed-8619-13fa779c3be4"},"path":[{"id":"c3778c81-f082-11ed-bad4-7be6b5b26589","type":"outgoing"},{"id":"bfed2d41-f082-11ed-bad4-7be6b5b26589","type":"outgoing"},{"id":"a5423df0-f082-11ed-a731-b353e52db9d0","type":"outgoing"},{"id":"97559640-f15b-11ed-8619-13fa779c3be4","type":"incoming"},{"id":"9a0992b0-f15b-11ed-8619-13fa779c3be4","type":"incoming"}],"ent_type":"Link"}', 1425, 500, 1424, 500, 0, '2023-05-13 07:01:22', '2023-05-13 07:01:22', null),
('f8b801c2-f15b-11ed-8a6e-3fd1cb46d16f', 'Link', '{"id":"f8b801c2-f15b-11ed-8a6e-3fd1cb46d16f","name":"LINK","anchor":{"x":2475,"y":600,"z":0,"t":0,"tag":""},"size":{"x":-1,"y":0,"z":0,"t":0,"tag":""},"parent":null,"children":[],"source":{"ref":"9a0992b0-f15b-11ed-8619-13fa779c3be4"},"destination":{"ref":"9b2b7d71-f15b-11ed-8619-13fa779c3be4"},"path":[{"id":"9a0992b0-f15b-11ed-8619-13fa779c3be4","type":"outgoing"},{"id":"9b2b7d71-f15b-11ed-8619-13fa779c3be4","type":"incoming"}],"ent_type":"Link"}', 2475, 600, 2474, 600, 0, '2023-05-13 07:01:24', '2023-05-13 07:01:24', null),
('fe05bbe2-f15b-11ed-8a6e-3fd1cb46d16f', 'Link', '{"id":"fe05bbe2-f15b-11ed-8a6e-3fd1cb46d16f","name":"LINK","anchor":{"x":2775,"y":650,"z":0,"t":0,"tag":""},"size":{"x":-1,"y":0,"z":0,"t":0,"tag":""},"parent":null,"children":[],"source":{"ref":"9b2b7d71-f15b-11ed-8619-13fa779c3be4"},"destination":{"ref":"a5d3f6a0-f082-11ed-a731-b353e52db9d0"},"path":[{"id":"9b2b7d71-f15b-11ed-8619-13fa779c3be4","type":"outgoing"},{"id":"97559640-f15b-11ed-8619-13fa779c3be4","type":"outgoing"},{"id":"a5d3f6a0-f082-11ed-a731-b353e52db9d0","type":"incoming"}],"ent_type":"Link"}', 2775, 650, 2774, 650, 0, '2023-05-13 07:01:33', '2023-05-13 07:01:33', null);
COMMIT;
