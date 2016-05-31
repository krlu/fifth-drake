package controllers;

import com.google.gson.Gson;
//import dataPipeline.FramePipeline;
import dataPipeline.FramePipeline;
import dataPipeline.models.trackingdata.ChampionTrackingData;
import models.FormSubmission;

//import ocr.OCR;
import org.bytedeco.javacpp.opencv_core.Mat;
import org.bytedeco.javacpp.opencv_core;
import play.data.Form;
import play.data.FormFactory;
import org.bytedeco.javacv.FrameGrabber;
import play.mvc.*;
import org.bytedeco.javacpp.opencv_imgcodecs;
import tracking.OpenCVTemplateMatching;
import views.html.*;

import java.awt.image.BufferedImage;
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

        return ok(index.render("test"));
    }

    public Result JarTester() throws Exception {

        Form<FormSubmission> userForm = ff.form(FormSubmission.class);
        FormSubmission submitted = userForm.bindFromRequest().get();

        String redTeam[] = {"Janna", "Azir", "Elise", "Azir", "Gragas"};
        String blueTeam[] = {"Janna", "Azir", "Janna", "Azir", "Janna"};

        OpenCVTemplateMatching tempMatch = new OpenCVTemplateMatching(redTeam, blueTeam);

        BufferedImage[] imageArray = new BufferedImage[10];
        List<Mat> matList = new ArrayList<Mat>();
        ChampionTrackingData[] champObjectArray;

        for (int p = 0; p < 10; p++)
        {
            BufferedImage full = tempMatch.loadBufferedImage("Data/res/TestFrames/" + "Frame" + p + ".png");
            imageArray[p] = tempMatch.cropImage(1620, 780, 300, 300, full);
            Optional <Mat> opt = tempMatch.imageToMat("Data/res/TestFrames/" + "Frame" + p + ".png");
            Mat screenMat = opt.orElseThrow(() -> new MissingResourceException("tst", "tst", "tst"));
            matList.add(screenMat);
        }

        champObjectArray = tempMatch.controlCenter(matList);
// //       OCR api = new OCR(Language.ENGLISH);
// //       OCR api = new OCR(OCR.Language.ENGLISH);
//
//        Mat[] matArray = list.toArray(new Mat[list.size()]);
//        api.performOCR(matArray);
//
//        String csv = api.getResultAsCSV();        int[] start = parseTime(submitted.getStart());
        int[] start = parseTime(submitted.getStart());
        int[] end = parseTime(submitted.getEnd());
        int[] ban = parseTime(submitted.getBan());
        int[] load = parseTime(submitted.getPregame());

        FramePipeline fp = new FramePipeline("https://www.youtube.com/watch?v=NVNLAdVL44w", start, end, ban, load, "public/vids/");
        List<Mat> list = fp.getFrames();
//        String s = String.valueOf(list.size());
//        api.close();
//
//        //this will return the swag that is the json file
        return ok(index.render(String.valueOf(list.size())));
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
