// @SOURCE:/Users/andrewsmith/Workspace/Courier/CourierServer/conf/routes
// @HASH:01d721dfdccb01b4b1cf6ffa7f4dd4c7b7198f40
// @DATE:Fri Mar 29 11:42:10 PDT 2013


import play.core._
import play.core.Router._
import play.core.j._

import play.api.mvc._


import Router.queryString

object Routes extends Router.Routes {

private var _prefix = "/"

def setPrefix(prefix: String) {
  _prefix = prefix  
  List[(String,Routes)]().foreach {
    case (p, router) => router.setPrefix(prefix + (if(prefix.endsWith("/")) "" else "/") + p)
  }
}

def prefix = _prefix

lazy val defaultPrefix = { if(Routes.prefix.endsWith("/")) "" else "/" } 


// @LINE:6
private[this] lazy val controllers_Application_index0 = Route("GET", PathPattern(List(StaticPart(Routes.prefix))))
        

// @LINE:9
private[this] lazy val controllers_Assets_at1 = Route("GET", PathPattern(List(StaticPart(Routes.prefix),StaticPart(Routes.defaultPrefix),StaticPart("assets/"),DynamicPart("file", """.+"""))))
        

// @LINE:11
private[this] lazy val controllers_Application_json2 = Route("GET", PathPattern(List(StaticPart(Routes.prefix),StaticPart(Routes.defaultPrefix),StaticPart("json"))))
        

// @LINE:12
private[this] lazy val controllers_Application_ping3 = Route("GET", PathPattern(List(StaticPart(Routes.prefix),StaticPart(Routes.defaultPrefix),StaticPart("ping/"),DynamicPart("code", """[^/]+"""))))
        

// @LINE:13
private[this] lazy val controllers_Application_post4 = Route("POST", PathPattern(List(StaticPart(Routes.prefix),StaticPart(Routes.defaultPrefix),StaticPart("post"))))
        
def documentation = List(("""GET""", prefix,"""controllers.Application.index"""),("""GET""", prefix + (if(prefix.endsWith("/")) "" else "/") + """assets/$file<.+>""","""controllers.Assets.at(path:String = "/public", file:String)"""),("""GET""", prefix + (if(prefix.endsWith("/")) "" else "/") + """json""","""controllers.Application.json"""),("""GET""", prefix + (if(prefix.endsWith("/")) "" else "/") + """ping/$code<[^/]+>""","""controllers.Application.ping(code:Long)"""),("""POST""", prefix + (if(prefix.endsWith("/")) "" else "/") + """post""","""controllers.Application.post""")).foldLeft(List.empty[(String,String,String)]) { (s,e) => e match {
  case r @ (_,_,_) => s :+ r.asInstanceOf[(String,String,String)]
  case l => s ++ l.asInstanceOf[List[(String,String,String)]] 
}}
       
    
def routes:PartialFunction[RequestHeader,Handler] = {        

// @LINE:6
case controllers_Application_index0(params) => {
   call { 
        invokeHandler(controllers.Application.index, HandlerDef(this, "controllers.Application", "index", Nil,"GET", """ Home page""", Routes.prefix + """"""))
   }
}
        

// @LINE:9
case controllers_Assets_at1(params) => {
   call(Param[String]("path", Right("/public")), params.fromPath[String]("file", None)) { (path, file) =>
        invokeHandler(controllers.Assets.at(path, file), HandlerDef(this, "controllers.Assets", "at", Seq(classOf[String], classOf[String]),"GET", """ Map static resources from the /public folder to the /assets URL path""", Routes.prefix + """assets/$file<.+>"""))
   }
}
        

// @LINE:11
case controllers_Application_json2(params) => {
   call { 
        invokeHandler(controllers.Application.json, HandlerDef(this, "controllers.Application", "json", Nil,"GET", """""", Routes.prefix + """json"""))
   }
}
        

// @LINE:12
case controllers_Application_ping3(params) => {
   call(params.fromPath[Long]("code", None)) { (code) =>
        invokeHandler(controllers.Application.ping(code), HandlerDef(this, "controllers.Application", "ping", Seq(classOf[Long]),"GET", """""", Routes.prefix + """ping/$code<[^/]+>"""))
   }
}
        

// @LINE:13
case controllers_Application_post4(params) => {
   call { 
        invokeHandler(controllers.Application.post, HandlerDef(this, "controllers.Application", "post", Nil,"POST", """""", Routes.prefix + """post"""))
   }
}
        
}
    
}
        