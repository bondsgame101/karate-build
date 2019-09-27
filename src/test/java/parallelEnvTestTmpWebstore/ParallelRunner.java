package parallelEnvTestTmpWebstore;

//import com.intuit.karate.FileUtils;
import com.intuit.karate.KarateOptions;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;
import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.io.FileUtils;

@KarateOptions(tags = {"~@ignore"})
class ParallelRunner {


    @Test
        void parallelRunner() {
            Results results = Runner.parallel(getClass(), 6);
            generateReport(results.getReportDir());
            assertTrue(results.getFailCount() == 0, results.getErrorMessages());
        }

        static void generateReport(String karateOutputPath) {
            Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] {"json"}, true);
            List<String> jsonPaths = new ArrayList(jsonFiles.size());
            jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
            Configuration config = new Configuration(new File("target/surefire-reports/parallel-reports"), "parallel-reports");
            ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
            reportBuilder.generateReports();
        }
    }


