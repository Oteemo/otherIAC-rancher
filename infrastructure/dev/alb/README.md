
For import of ALB, please remove these fields per resource type

## aws_lb

* arn
* arn suffix
* ds_name
* id
* zone_id

## aws_lb_listener

* arn
* id

Replace 'loadbalancer_arn' with 'load_balancer_arn = aws_lb.aspace_pui.arn'


## aws_lb_target_group

* arn
* arn_suffix
* id
* loadbalancer_arn

