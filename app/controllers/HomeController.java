package controllers;

import org.bytedeco.javacv.FrameGrabber;
import play.data.FormFactory;
import play.mvc.Controller;
import play.mvc.Result;

import java.io.FileNotFoundException;
import javax.inject.Inject;

/**
 * This controller contains an action to handle HTTP requests
 * to the application's home page.
*/
public class HomeController extends Controller {

    @Inject FormFactory ff;

    public Result index() throws FileNotFoundException, FrameGrabber.Exception {
        return null;
    }
}
