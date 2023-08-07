module users

import net.http
import json

pub struct Token{
pub mut:
	access_token string
	expires_in i32
	scope string
	token_type string
}
pub struct KindeApi{
pub mut:
	domain string = "https://inflow.kinde.com"
	audience string = "https://inflow.kinde.com/api"
	client_id string
	secret string
	proxy_authorization string
	token Token
}
pub fn (mut ka KindeApi) get_client_credentials() ! {
	body := [
		"grant_type=client_credentials"
		"client_id=${ka.client_id}"
		"client_secret=${ka.secret}"
	].join("&")

	println("fetching client credentials")
	mut req := http.new_request(.post,"${ka.domain}/oauth2/token",body)
	req.header.add(.accept,"*/*")
	req.header.add(.content_type,"application/x-www-form-urlencoded")
	req.header.add(.connection,"keep-alive")
	req.header.add(.accept_encoding,"gzip, deflate, br")
	req.header.add(.user_agent,"v-backend/1.36.1")
	req.header.add(.content_length,"${body.len}")
	//if ka.proxy_authorization != "" {
		req.header.add(.proxy_authorization,ka.proxy_authorization)
	//}
	req.verbose=true
	req.allow_redirect
	println("sending request ${req}")
	res:=req.do() or {
		println("failed to fetch client credentials")
		panic(err)
	}
	ka.token=json.decode(Token,res.body) or {
		println("failed to decode client credentials")
		panic(err)
	}

}
pub fn (ka KindeApi) get_users() ! {
	mut req :=  http.new_request(.get,"${ka.domain}/api/v1/users","")
	req.header.add(.accept,"application/json")
	req.header.add(.authorization,"Bearer ${ka.token.access_token}")
	req.do() or {
		panic(err)
	}
}
