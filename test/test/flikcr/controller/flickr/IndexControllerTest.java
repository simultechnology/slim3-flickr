package test.flikcr.controller.flickr;

import org.slim3.tester.ControllerTestCase;
import org.junit.Test;

import test.flikcr.controller.flikcr.IndexController;
import static org.junit.Assert.*;
import static org.hamcrest.CoreMatchers.*;

public class IndexControllerTest extends ControllerTestCase {

    @Test
    public void run() throws Exception {
        tester.start("/flikcr/");
        IndexController controller = tester.getController();
        assertThat(controller, is(notNullValue()));
        assertThat(tester.isRedirect(), is(false));
        assertThat(tester.getDestinationPath(), is("/flikcr/index.jsp"));
    }
}
