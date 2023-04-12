module dbsql

import geometry


fn test_simple(){
	mut s:=SqlitePool{}
	s.specifier='test.file.db'
	println(s)
	mut rcode:=s.query("DROP table test")!
	println("$rcode")
	rcode=s.query("create table test(id varchar(255) primary key not null,data varchar(255))")!
	println("$rcode")
	rcode=s.query("insert into test(id,data) values ('a','afdasdf asdfasdf asdfasdf ');COMMIT;")!
	println("$rcode")
	rcode=s.query("insert into test(id,data) values ('b','afdasdf asdfasdf asdfasdf ');")!
	println("$rcode")
	rcode=s.query("select MAX(id) FROM BOXES;")!
	println("$rcode")
	id:=rcode.rows[0].vals[0].u64()
	j:='{"id":${id+1},"anchor":{"x":1,"y":-13},"size":{"x":10,"y":10}}'
	q:="
		INSERT INTO BOXES(id,ent_type,json,x0,y0,x1,y1,visible_size)
		VALUES ('${id+1}','generic','$j',1.0,-13.0,11.0,-3.0,10.0);
	"
	println("executing $q")
	rcode=s.query(q)!
	println("$rcode")
}

fn test_service(){
	mut s:=SqlitePool{}
	s.specifier='test.file.db'
	mut rcode:=s.query("select MAX(id) FROM BOXES;")!
	println("$rcode")
	id:=rcode.rows[0].vals[0].u64()
	j:='{"id":${id+1},"anchor":{"x":1,"y":-13},"size":{"x":10,"y":10}}'
	s.store_entities([geometry.Entity{
		id:'${id+1}',
		ent_type: 'Box',
		json: j
	}])!
}
