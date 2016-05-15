package controllers;
import MiniMapSearch.OpenCVTemplateMatching;
import com.google.gson.Gson;
import dataPipeline.FramePipeline;
import models.FormSubmission;
import ocr.Frame;
import ocr.LoLTemplate.*;
import ocr.*;
import org.bytedeco.javacpp.opencv_core.Mat;
import org.bytedeco.javacpp.opencv_core;
import play.data.Form;
import play.data.FormFactory;
import org.bytedeco.javacv.FrameGrabber;
import play.mvc.*;
import org.bytedeco.javacpp.opencv_imgcodecs;
import views.html.*;
import java.io.FileNotFoundException;
import java.util.*;
import org.bytedeco.javacpp.opencv_imgproc;

import javax.inject.Inject;



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
        return ok(index.render("This is where the JSON will populate the page."));
    }

    public Result JarTester() throws FileNotFoundException, FrameGrabber.Exception{

        Form<FormSubmission> userForm = ff.form(FormSubmission.class);
        FormSubmission submitted = userForm.bindFromRequest().get();


        int[] start = parseTime(submitted.getStart());
        int[] end = parseTime(submitted.getEnd());
        int[] ban = parseTime(submitted.getBan());
        int[] pregame = parseTime(submitted.getPregame());

        //for the demo, just run youtube-dl on this URL, and put it into your local folder
        FramePipeline fp = new FramePipeline("https://www.youtube.com/watch?v=NVNLAdVL44w", start, end, ban, pregame, "public/vids/");
        initIcons();
        String id = fp.parseYouTubeID("https://www.youtube.com/watch?v=NVNLAdVL44w");
        List<Mat> list = fp.getFrames();


        /*

        JSON STRUCTURE:

        id : {
             blueTeam(frame#) : [
                            {champName : "champName",
                            "x" : double,
                            "y" : double},
                            .
                            .
                            ],
             redTeam(frame#) : [
                           .
                           .
                           ],
             }
         */

        Map<String, Object> timeStamps = new HashMap<String, Object>();
        for(int i = 0; i < list.size(); i++){
            //its duplicated but i'm too tired to make efficiencies
            Mat minimap = OpenCVTemplateMatching.crop1080pMiniMap(list.get(i));
            ArrayList<Object> blueTeamInstance = new ArrayList<Object>();

            for(String key : blueMap.keySet()){
                Map<String, Object> playerInstance = new HashMap<String, Object>();

                double[] locs = OpenCVTemplateMatching.templateMatch(minimap, blueMap.get(key));

                playerInstance.put("champName", key);
                playerInstance.put("x", locs[0]);
                playerInstance.put("y", locs[1]);

                blueTeamInstance.add(playerInstance);
            }

            ArrayList<Object> redTeamInstance = new ArrayList<Object>();
            for(String key : redMap.keySet()){
                Map<String, Object> playerInstance = new HashMap<String, Object>();

                double[] locs = OpenCVTemplateMatching.templateMatch(minimap, redMap.get(key));

                playerInstance.put("champName", key);
                playerInstance.put("x", locs[0]);
                playerInstance.put("y", locs[1]);
                redTeamInstance.add(playerInstance);
            }

            timeStamps.put("blueTeam" + i, blueTeamInstance);
            timeStamps.put("redTeam" + i, redTeamInstance);
        }
        json.put(id, timeStamps);
        System.out.println(json.size());



        /****HAD TO COMMENT OUT B/C OF MONGODB ERROR****
         Frame banFrame = new Frame(banScreen, LoLTag.BANPHASE);
         OCR api = new OCR("eng", t);
         api.performOCR(banFrame);
         Map<String, Object> map = t.getOCRResults();
         Gson gson = new Gson();
         String json = gson.toJson(map);*/

        //opencv_imgcodecs.imwrite("public/images/banScreen.png", banScreen);
        //opencv_imgcodecs.imwrite("public/images/loadScreen.png", loadScreen);

        //this will return the swag that is the json file
        return ok(index.render(""));
    }




    public int[] parseTime(String str) {
        int[] ret = new int[3];
        String[] temp = str.split(":");
        if(temp.length > 2){
            ret[0] = Integer.parseInt(temp[0]);
            ret[1] = Integer.parseInt(temp[1]);
            ret[2] = Integer.parseInt(temp[2]);
        } else {
            ret[1] = Integer.parseInt(temp[0]);
            ret[2] = Integer.parseInt(temp[1]);
        }

        return ret;
    }

    public void initIcons(){
        for(String champ : blueChamps) {
            Mat m = opencv_imgcodecs.imread("public/icons/" + champ + ".png");
            blueMap.put(champ, m);
        }
        for(String champ : redChamps) {
            Mat m = opencv_imgcodecs.imread("public/icons/" + champ + ".png");
            redMap.put(champ, m);
        }
    }


//    public Result test() throws FileNotFoundException, FrameGrabber.Exception {
//        System.out.println("this tests works!");
//
//        Form<FormSubmission> userForm = formFactory.form(FormSubmission.class);
//        FormSubmission fs = userForm.bindFromRequest().get();
//        System.out.println(fs.getLink());
//        System.out.println(fs.getStart());
//        return redirect(routes.HomeController.index());
//    }


}
