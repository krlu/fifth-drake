package controllers;

import org.bytedeco.javacpp.opencv_core.Mat;
import org.bytedeco.javacv.FrameGrabber;
import play.data.FormFactory;
import play.mvc.Controller;
import play.mvc.Result;

import javax.inject.Inject;
import java.io.FileNotFoundException;
import java.util.HashMap;
import java.util.Map;

//import dataPipeline.FramePipeline;
//import ocr.OCR;

/**
 * This controller contains an action to handle HTTP requests
 * to the application's home page.
*/
public class HomeController extends Controller {

    @Inject FormFactory ff;
    /**
     * An action that renders an HTML page with a welcome message.
     * The configuration in the <code>routes</code> file means that
     * this method will be called when the application receives a
     * <code>GET</code> request with a path of <code>/</code>.
     */
    private String[] blueChamps = {"poppy", "graves", "lulu", "kalista", "alistar"};
    private String[] redChamps = {"ekko", "reksai", "corki", "caitlyn", "morgana"};

    Map<String, Mat> blueMap = new HashMap<String, Mat>();
    Map<String, Mat> redMap = new HashMap<String, Mat>();
    Map<String, Object> json = new HashMap<String, Object>();
    //LoLTemplate t = new LoLTemplate();

    public Result index() throws FileNotFoundException, FrameGrabber.Exception {
        return null;
    }

    public Result JarTester() throws Exception {


        return null;
    }
    public void initIcons(){
    }
}
