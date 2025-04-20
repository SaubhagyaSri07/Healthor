import 'package:json_annotation/json_annotation.dart';

     part 'condition.g.dart';

     @JsonSerializable()
     class Condition {
       final String id;
       final String name;
       final double probability;
       final String? triage;

       Condition({
         required this.id,
         required this.name,
         required this.probability,
         this.triage,
       });

       factory Condition.fromJson(Map<String, dynamic> json) => _$ConditionFromJson(json);
       Map<String, dynamic> toJson() => _$ConditionToJson(this);
     }