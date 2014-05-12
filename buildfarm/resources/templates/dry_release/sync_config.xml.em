<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description>Generated job to create binary debs for dry stack "@(PACKAGE)". DO NOT EDIT BY HAND. Generated by buildfarm/scripts/create_release_jobs.py for @(USERNAME) at @(TIMESTAMP)</description>
  <logRotator>
    <daysToKeep>180</daysToKeep>
    <numToKeep>20</numToKeep>
    <artifactDaysToKeep>30</artifactDaysToKeep>
    <artifactNumToKeep>-1</artifactNumToKeep>
  </logRotator>
  <keepDependencies>false</keepDependencies>
  <properties>
  </properties>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@@1.1.25">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <name/>
        <refspec/>
        <url>https://github.com/ros-infrastructure/buildfarm.git</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>master</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <disableSubmodules>false</disableSubmodules>
    <recursiveSubmodules>false</recursiveSubmodules>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <authorOrCommitter>false</authorOrCommitter>
    <clean>false</clean>
    <wipeOutWorkspace>false</wipeOutWorkspace>
    <pruneBranches>false</pruneBranches>
    <remotePoll>false</remotePoll>
    <ignoreNotifyCommit>false</ignoreNotifyCommit>
    <useShallowClone>false</useShallowClone>
    <buildChooser class="hudson.plugins.git.util.DefaultBuildChooser"/>
    <gitTool>Default</gitTool>
    <submoduleCfg class="list"/>
    <relativeTargetDir>buildfarm</relativeTargetDir>
    <reference/>
    <excludedRegions/>
    <excludedUsers/>
    <gitConfigName/>
    <gitConfigEmail/>
    <skipTag>false</skipTag>
    <includedRegions/>
    <scmName/>
  </scm>
  <assignedNode>sync</assignedNode>
  <canRoam>false</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>true</blockBuildWhenUpstreamBuilding>
  <authToken>RELEASE_BUILD_DEBS</authToken>
  <triggers class="vector"/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>@(COMMAND)</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers>
    <org.jvnet.hudson.plugins.groovypostbuild.GroovyPostbuildRecorder plugin="groovy-postbuild@@1.8">
      <groovyScript>
// CHECK FOR VARIOUS REASONS TO RETRIGGER JOB
// also triggered when a build step has failed
import hudson.model.Cause
import org.jvnet.hudson.plugins.groovypostbuild.GroovyPostbuildAction

def reschedule_build(msg) {
	pb = manager.build.getPreviousBuild()
	if (pb) {
		ba = pb.getBadgeActions()
		for (b in ba) {
			if (b instanceof GroovyPostbuildAction) {
				if (b.getText().contains(msg)) {
					manager.addInfoBadge("Log contains '" + msg + "' - skip rescheduling new build since previous build contains the same badge")
					return
				}
			}
		}
	}
	manager.addInfoBadge("Log contains '" + msg + "' - scheduled new build...")
	manager.build.project.scheduleBuild(new Cause.UserIdCause())
}

if (manager.logContains(".*W: Failed to fetch .* Hash Sum mismatch.*")) {
	reschedule_build("Hash Sum mismatch")
} else if (manager.logContains(".*The lock file '/var/www/repos/building/db/lockfile' already exists.*")) {
	reschedule_build("building/db/lockfile already exists")
} else if (manager.logContains(".*E: Could not get lock /var/lib/dpkg/lock - open \\(11: Resource temporarily unavailable\\).*")) {
	reschedule_build("dpkg/lock temporary unavailable")
} else if (manager.logContains(".*ERROR: cannot download default sources list from:.*")) {
	reschedule_build("cannot download default sources list")
} else if (manager.logContains(".*ERROR: Not all sources were able to be updated.*")) {
	reschedule_build("Not all sources were able to be updated")
} else if (manager.logContains(".*hudson.plugins.git.GitException: Could not clone.*")) {
  reschedule_build("Could not clone")
}
</groovyScript>
      <behavior>0</behavior>
    </org.jvnet.hudson.plugins.groovypostbuild.GroovyPostbuildRecorder>
    <hudson.tasks.BuildTrigger>
      <childProjects>@(','.join(CHILD_PROJECTS))</childProjects>
      <threshold>
        <name>SUCCESS</name>
        <ordinal>0</ordinal>
        <color>BLUE</color>
      </threshold>
    </hudson.tasks.BuildTrigger>
    <hudson.tasks.Mailer>
      <recipients>ros-buildfarm-release@@googlegroups.com @(NOTIFICATION_EMAIL)</recipients>
      <dontNotifyEveryUnstableBuild>false</dontNotifyEveryUnstableBuild>
      <sendToIndividuals>false</sendToIndividuals>
    </hudson.tasks.Mailer>
    <hudson.plugins.parameterizedtrigger.BuildTrigger plugin="parameterized-trigger@2.22">
      <configs>
        <hudson.plugins.parameterizedtrigger.BuildTriggerConfig>
          <configs>
            <hudson.plugins.parameterizedtrigger.PredefinedBuildParameters>
              <properties>
                token=EXPORT_SHADOW_FIXED cause="Succesful build of @(PACKAGE)"
              </properties>
            </hudson.plugins.parameterizedtrigger.PredefinedBuildParameters>
          </configs>
          <projects>_export-shadow-fixed,</projects>
          <condition>SUCCESS</condition>
          <triggerWithNoParameters>false</triggerWithNoParameters>
        </hudson.plugins.parameterizedtrigger.BuildTriggerConfig>
      </configs>
    </hudson.plugins.parameterizedtrigger.BuildTrigger>
  </publishers>
  <buildWrappers/>
</project>
