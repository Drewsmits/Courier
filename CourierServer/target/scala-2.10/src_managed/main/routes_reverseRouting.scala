// @SOURCE:/Users/andrewsmith/Workspace/Courier/CourierServer/conf/routes
// @HASH:01d721dfdccb01b4b1cf6ffa7f4dd4c7b7198f40
// @DATE:Fri Mar 29 11:42:10 PDT 2013

import Routes.{prefix => _prefix, defaultPrefix => _defaultPrefix}
import play.core._
import play.core.Router._
import play.core.j._

import play.api.mvc._


import Router.queryString


// @LINE:13
// @LINE:12
// @LINE:11
// @LINE:9
// @LINE:6
package controllers {

// @LINE:13
// @LINE:12
// @LINE:11
// @LINE:6
class ReverseApplication {
    

// @LINE:13
def post(): Call = {
   Call("POST", _prefix + { _defaultPrefix } + "post")
}
                                                

// @LINE:11
def json(): Call = {
   Call("GET", _prefix + { _defaultPrefix } + "json")
}
                                                

// @LINE:6
def index(): Call = {
   Call("GET", _prefix)
}
                                                

// @LINE:12
def ping(code:Long): Call = {
   Call("GET", _prefix + { _defaultPrefix } + "ping/" + implicitly[PathBindable[Long]].unbind("code", code))
}
                                                
    
}
                          

// @LINE:9
class ReverseAssets {
    

// @LINE:9
def at(file:String): Call = {
   Call("GET", _prefix + { _defaultPrefix } + "assets/" + implicitly[PathBindable[String]].unbind("file", file))
}
                                                
    
}
                          
}
                  


// @LINE:13
// @LINE:12
// @LINE:11
// @LINE:9
// @LINE:6
package controllers.javascript {

// @LINE:13
// @LINE:12
// @LINE:11
// @LINE:6
class ReverseApplication {
    

// @LINE:13
def post : JavascriptReverseRoute = JavascriptReverseRoute(
   "controllers.Application.post",
   """
      function() {
      return _wA({method:"POST", url:"""" + _prefix + { _defaultPrefix } + """" + "post"})
      }
   """
)
                        

// @LINE:11
def json : JavascriptReverseRoute = JavascriptReverseRoute(
   "controllers.Application.json",
   """
      function() {
      return _wA({method:"GET", url:"""" + _prefix + { _defaultPrefix } + """" + "json"})
      }
   """
)
                        

// @LINE:6
def index : JavascriptReverseRoute = JavascriptReverseRoute(
   "controllers.Application.index",
   """
      function() {
      return _wA({method:"GET", url:"""" + _prefix + """"})
      }
   """
)
                        

// @LINE:12
def ping : JavascriptReverseRoute = JavascriptReverseRoute(
   "controllers.Application.ping",
   """
      function(code) {
      return _wA({method:"GET", url:"""" + _prefix + { _defaultPrefix } + """" + "ping/" + (""" + implicitly[PathBindable[Long]].javascriptUnbind + """)("code", code)})
      }
   """
)
                        
    
}
              

// @LINE:9
class ReverseAssets {
    

// @LINE:9
def at : JavascriptReverseRoute = JavascriptReverseRoute(
   "controllers.Assets.at",
   """
      function(file) {
      return _wA({method:"GET", url:"""" + _prefix + { _defaultPrefix } + """" + "assets/" + (""" + implicitly[PathBindable[String]].javascriptUnbind + """)("file", file)})
      }
   """
)
                        
    
}
              
}
        


// @LINE:13
// @LINE:12
// @LINE:11
// @LINE:9
// @LINE:6
package controllers.ref {

// @LINE:13
// @LINE:12
// @LINE:11
// @LINE:6
class ReverseApplication {
    

// @LINE:13
def post(): play.api.mvc.HandlerRef[_] = new play.api.mvc.HandlerRef(
   controllers.Application.post(), HandlerDef(this, "controllers.Application", "post", Seq(), "POST", """""", _prefix + """post""")
)
                      

// @LINE:11
def json(): play.api.mvc.HandlerRef[_] = new play.api.mvc.HandlerRef(
   controllers.Application.json(), HandlerDef(this, "controllers.Application", "json", Seq(), "GET", """""", _prefix + """json""")
)
                      

// @LINE:6
def index(): play.api.mvc.HandlerRef[_] = new play.api.mvc.HandlerRef(
   controllers.Application.index(), HandlerDef(this, "controllers.Application", "index", Seq(), "GET", """ Home page""", _prefix + """""")
)
                      

// @LINE:12
def ping(code:Long): play.api.mvc.HandlerRef[_] = new play.api.mvc.HandlerRef(
   controllers.Application.ping(code), HandlerDef(this, "controllers.Application", "ping", Seq(classOf[Long]), "GET", """""", _prefix + """ping/$code<[^/]+>""")
)
                      
    
}
                          

// @LINE:9
class ReverseAssets {
    

// @LINE:9
def at(path:String, file:String): play.api.mvc.HandlerRef[_] = new play.api.mvc.HandlerRef(
   controllers.Assets.at(path, file), HandlerDef(this, "controllers.Assets", "at", Seq(classOf[String], classOf[String]), "GET", """ Map static resources from the /public folder to the /assets URL path""", _prefix + """assets/$file<.+>""")
)
                      
    
}
                          
}
                  
      