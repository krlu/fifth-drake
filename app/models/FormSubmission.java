package models;

import com.avaje.ebean.Model;

import javax.persistence.Entity;
import java.util.Collection;
import java.util.Map;

/**
 * Created by Owner on 5/14/2016.
 */

@Entity
public class FormSubmission extends Model {
    public String link;
    public String ban;
    public String pregame;
    public String start;
    public String end;

    public String getLink() {
        return link;
    }

    public void setLink(String link) {
        this.link = link;
    }

    public String getBan() {
        return ban;
    }

    public void setBan(String ban) {
        this.ban = ban;
    }

    public String getPregame() {
        return pregame;
    }

    public void setPregame(String pregame) {
        this.pregame = pregame;
    }

    public String getStart() {
        return start;
    }

    public void setStart(String start) {
        this.start = start;
    }

    public String getEnd() {
        return end;
    }
    public void setEnd(String end) {
        this.end = end;
    }

}
