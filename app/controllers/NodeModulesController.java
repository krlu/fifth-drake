package controllers;

import play.mvc.*;
import java.io.File;

public class NodeModulesController extends Controller {

    public Result at(String filePath) {
        File file = new File("node_modules/" + filePath);
        return ok(file, true);
    }
}