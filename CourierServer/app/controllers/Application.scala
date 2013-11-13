package controllers

import scala.concurrent.Future
import play.api.libs.concurrent.Execution.Implicits._
import play.api.mvc._
import play.api.libs.json.Json
import scala.util.Random

object Application extends Controller {

  def logRequest(request: Request[AnyContent]) = {
    println("[LOG]: " + request)
  }


  def index = Action {
    Ok
  }

  /**
   * Get a response from the server with a custom status code
   * @param statusCode
   * @return Result
   */
  def ping(statusCode: Int) = Action { request =>
    logRequest(request)
    if (statusCode > 999) {
      // HTTP limits status codes to 3 or less digits
      BadRequest
    } else {
      Status(statusCode)
    }
  }

  def testJsonGet = Action { request =>
      logRequest(request)
      val result = scala.concurrent.Future {
        val imageList = List.tabulate(50)(n => {
          Map("key" -> "value_%03d.png".format(n + 1))
        })
        Ok(Json.toJson(imageList))
      }
      Async(
        result
      )
  }

//  def testJsonGet = Action { request =>
////    logRequest(request)
////    val result = scala.concurrent.Future {
////      val imageList = List.tabulate(10000)(n => {
////        Map("key" -> "value_%03d.png".format(n + 1))
////      })
////      Ok(Json.toJson(imageList))
////    }
////    Async(
////      result
////    )
//
//    val result = scala.concurrent.Future {
//      val sleep = 1 + Random.nextInt(4 - 1 + 1)
//      Thread.sleep(sleep * 1000)
//      val time = Map("sleepTime" -> sleep)
//      Ok(Json.toJson(time))
//    }
//    Async(
//      result
//    )
//
////    Thread.sleep(2000)
////
////    val imageList = List.tabulate(1000)(n => {
////      Map("key" -> "value_%03d.png".format(n + 1))
////    })
////    Ok(Json.toJson(imageList))
//  }

  def testJsonPost = Action(parse.json) { request =>
    (request.body \ "name").asOpt[String].map { name =>
      if (name == "Drewsmits") {
        Ok
      } else {
        BadRequest("Incorrect parameter for [name]. Expected 'Drewsmits', got " + name)
      }
    }.getOrElse {
      BadRequest("Missing parameter [name]")
    }
  }

  def longRequest(sleepLength: Long)  = Action {
    val futureInt: Future[Int] = Future {
      Thread.sleep(sleepLength)
      1
    }
    Async {
      futureInt.map(i => Ok)
    }
  }

  def getTest = Action {
    Ok
  }

  def postTest = Action {
    Ok
  }

  def putTest = Action {
    Ok
  }

  def deleteTest = Action {
    println("got here")
    Ok
  }

  def listOfImages = Action { request =>
    logRequest(request)
    val result = scala.concurrent.Future {
      val imageList = List.tabulate(383)(n => {
        Map("imageUrl" -> "http://10.0.1.3:9000/assets/images/thumbnails/thumbnail_%03d.png".format(n + 1))
//        Map("imageUrl" -> "http://192.168.1.152:9000/assets/images/small-thumbnails/thumbnail_%03d.jpg".format(n + 1))
      })
      Ok(Json.toJson(imageList))
    }
    Async(
      result
    )
  }

  def authenticationChallenge = Action { request =>
    logRequest(request)

  }
}