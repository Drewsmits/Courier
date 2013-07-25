
package views.html

import play.templates._
import play.templates.TemplateMagic._

import play.api.templates._
import play.api.templates.PlayMagic._
import models._
import controllers._
import play.api.i18n._
import play.api.mvc._
import play.api.data._
import views.html._
/**/
object index extends BaseScalaTemplate[play.api.templates.Html,Format[play.api.templates.Html]](play.api.templates.HtmlFormat) with play.api.templates.Template1[String,play.api.templates.Html] {

    /**/
    def apply/*1.2*/(message: String):play.api.templates.Html = {
        _display_ {

Seq[Any](format.raw/*1.19*/("""

"""),_display_(Seq[Any](/*3.2*/main("Welcome to Play 2.1")/*3.29*/ {_display_(Seq[Any](format.raw/*3.31*/("""
    
    """),_display_(Seq[Any](/*5.6*/play20/*5.12*/.welcome(message))),format.raw/*5.29*/("""
    
""")))})),format.raw/*7.2*/("""
"""))}
    }
    
    def render(message:String): play.api.templates.Html = apply(message)
    
    def f:((String) => play.api.templates.Html) = (message) => apply(message)
    
    def ref: this.type = this

}
                /*
                    -- GENERATED --
                    DATE: Fri Mar 29 10:03:12 PDT 2013
                    SOURCE: /Users/andrewsmith/Workspace/Courier/CourierServer/app/views/index.scala.html
                    HASH: 37eefd9454dbf77b8088e94c3ec99cc2c62f71c9
                    MATRIX: 505->1|599->18|636->21|671->48|710->50|755->61|769->67|807->84|844->91
                    LINES: 19->1|22->1|24->3|24->3|24->3|26->5|26->5|26->5|28->7
                    -- GENERATED --
                */
            