// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Condition _$ConditionFromJson(Map<String, dynamic> json) => Condition(
      id: json['id'] as String,
      name: json['name'] as String,
      probability: (json['probability'] as num).toDouble(),
      triage: json['triage'] as String?,
    );

Map<String, dynamic> _$ConditionToJson(Condition instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'probability': instance.probability,
      'triage': instance.triage,
    };
