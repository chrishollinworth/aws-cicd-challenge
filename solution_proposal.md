# Solution Proposal Documentation

## 1. How to Notify Resource Owners about misconfigured resources without too many notifications.

Echo notifications back to the user on build before resources can be provisioned.

Rather than overload users with email notifications for repository event, PR based notifications would provide a central view.

## 2. How To Eliminate Misconfigured Resource.

### cfn-lint custom rules

https://github.com/aws-cloudformation/cfn-lint/blob/main/docs/getting_started/rules.md
https://kevinhakanson.com/2021-06-30-aws-cloudformation-linter-custom-rules

### Using Proactive Compliance with AWS Config - AWS Config Custom Rules

https://aws.amazon.com/about-aws/whats-new/2022/11/aws-config-rules-support-proactive-compliance/
https://aws.amazon.com/blogs/aws/new-aws-config-rules-now-support-proactive-compliance/

Proactive compliance is currently available in US East (Ohio, N. Virginia) and US West (N. California, Oregon). 
