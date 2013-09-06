package controllers

import scala.concurrent.Future
import play.api.libs.concurrent.Execution.Implicits._
import play.api.mvc._
import play.api.libs.json.Json

object Application extends Controller {
  
  def index = Action {
    Ok
  }

  /**
   * Get a response from the server with a custom status code
   * @param statusCode
   * @return Result
   */
  def ping(statusCode: Int) = Action {
    if (statusCode > 999) {
      // HTTP limits status codes to 3 or less digits
      BadRequest
    } else {
      println("Heard the request")
      Status(statusCode)
    }
  }

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

  def listOfImages = Action {
    val result = scala.concurrent.Future {
      val imageList = List.tabulate(383)(n => {
      Map("imageUrl" -> "http://10.0.1.3:9000/assets/images/thumbnails/thumbnail_%03d.png".format(n + 1))
      })
      Ok(Json.toJson(imageList))
    }
    Async(
      result
    )
  }
}