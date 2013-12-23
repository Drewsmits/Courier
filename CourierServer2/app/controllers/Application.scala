package controllers

import play.api._
import play.api.mvc._

object Application extends Controller {
  
  def index = Action {
    Ok(views.html.index("Your new application is ready."))
  }

  def logRequest(request: Request[AnyContent]) = {
    println("[LOG]: " + request)
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
}