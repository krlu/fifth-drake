package controllers;

import com.google.gson.Gson;
//import dataPipeline.FramePipeline;
import dataPipeline.FramePipeline;
import dataPipeline.dbhandling.FrameData;
import dataPipeline.dbhandling.PostgresFrameDataHandler;
import dataPipeline.dbhandling.PostgresRiotDataHandler;
import dataPipeline.dbhandling.RiotData;
import dataPipeline.models.RiotID;
import dataPipeline.models.trackingdata.ChampionTrackingData;
import models.FormSubmission;

//import ocr.OCR;
import ocr.OCR;
import org.bytedeco.javacpp.opencv_core.Mat;
import org.bytedeco.javacpp.opencv_core;
import play.data.Form;
import play.data.FormFactory;
import org.bytedeco.javacv.FrameGrabber;
import play.mvc.*;
import org.bytedeco.javacpp.opencv_imgcodecs;
import riot.RiotPipeline;
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
        String link = submitted.getLink();
        int[] start = parseTime(submitted.getStart());
        int[] end = parseTime(submitted.getEnd());
        int[] ban = parseTime(submitted.getBan());
        int[] load = parseTime(submitted.getPregame());

        FramePipeline fp = new FramePipeline(link, start, end, ban, load, "C:/Users/Kenneth/" +
                "Documents/GitHub/esportsAnalyticsWeb/public/vids/");
        System.out.println("getting frames....");
        List<Mat> list = fp.getFrames();

        String redTeam[] = {"Ekko", "RekSai", "Corki", "Caitlyn", "Morgana"};
        String blueTeam[] = {"Poppy", "Graves", "Lulu", "Kalista", "Alistar"};

        OpenCVTemplateMatching tempMatch = new OpenCVTemplateMatching(redTeam, blueTeam);
        FrameData psql = new PostgresFrameDataHandler("localhost", 5432, "league_analytics", "postgres", "123");

        System.out.println("ocr.tessdataPath: " + System.getProperty("ocr.tessdataPath"));
        OCR ocr = new OCR(OCR.Language.ENGLISH);
        ocr.performOCR(list.toArray(new Mat[0]));
        ocr.getResults(psql);

        ChampionTrackingData[] champObjectArray = tempMatch.controlCenter(list, fp.parseYouTubeID(link));
        for(ChampionTrackingData ctd : champObjectArray)
            psql.addTrackingData(ctd);

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
}
