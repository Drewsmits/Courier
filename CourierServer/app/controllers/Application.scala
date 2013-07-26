package controllers

import play.api._
import play.api.mvc._

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
      Status(statusCode)
    }
  }

  def testJson = Action(parse.json) { request =>
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
}