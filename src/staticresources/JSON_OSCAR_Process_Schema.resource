{
	"$schema": "http://json-schema.org/draft-04/schema#",
	"type": "object",
	"properties": {
		"AMS_OSCAR_JSON": {
			"type": "object",
			"properties": {
				"Processes": {
					"type": "array",
					"minItems": 1,
					"items": {
						"type": "object",
						"minItems": 1,
						"properties": {
							"Name": {
								"type": "string"
							},
							"Flows": {
								"type": "array",
								"minItems": 1,
								"items": {
									"type": "object",
									"properties": {
										"Name": {
											"type": "string"
										},
										"Steps": {
											"type": "array",
											"minItems": 1,
											"items": {
												"type": "object",
												"properties": {
													"Name": {
														"type": "string"
													},
													"Required": {
														"type": "array",
														"items": {
															"type": "string"
														},
														"uniqueItems": true
													},
													"Actions": {
														"type": "array",
														"minItems": 0,
														"items": {
															"type": "object",
															"properties": {
																"FunctionName": {
																	"type": "string"
																},
																"ActionLabel": {
																	"type": "string"
																},
																"args": {
																	"type": "array",
																	"minItems": 0,
																	"items": {
																		"type": "string"
																	}
																}
															},
															"required": ["FunctionName",
															"ActionLabel"],
															"additionalProperties": false,
															"uniqueItems": true
														}
													},
													"Automations": {
														"type": "array",
														"minItems": 0,
														"items": {
															"type": "object",
															"properties": {
																"Status": {
																	"type": "string"
																},
																"ClassName": {
																	"type": "string"
																},
																"ChangeCode": {
																	"type": "object",
																	"properties": {
																		"Name": {
																			"type": "string"
																		},
																		"ReasonCode": {
																			"type": "string"
																		},
																		"MemoText": {
																			"type": "string"
																		},
																		"ReasonDesc": {
																			"type": "string"
																		},
																		"Status": {
																			"type": "string"
																		}
																	},
																	"required": ["Name",
																	"ReasonCode",
																	"MemoText",
																	"ReasonDesc",
																	"Status"],
																	"additionalProperties": false,
																	"uniqueItems": true
																}
															},
															"required": ["Status",
															"ClassName"],
															"additionalProperties": false,
															"uniqueItems": true
														}
													},
													"DisplayFields": {
														"Required": {
															"type": "array",
															"items": {
																"type": "string"
															}
														},
														"additionalProperties": false,
														"uniqueItems": true,
														"minItems": 1
													},
													"IsDependent": {
														"type": "boolean"
													}
												},
												"required": ["Name",
												"Required",
												"Actions",
												"Automations",
												"DisplayFields",
												"IsDependent"],
												"additionalProperties": false,
												"uniqueItems": true,
												"minItems": 1
											}
										}
									},
									"required": ["Name",
									"Steps"],
									"additionalProperties": false,
									"maxProperties": 2
								},
								"additionalProperties": false,
								"uniqueItems": true
							}
						},
						"required": ["Name",
						"Flows"]
					},
					"uniqueItems": true,
					"additionalProperties": false
				}
			},
			"uniqueItems": true,
			"additionalProperties": false,
			"required": ["Processes"],
			"maxItems": 1
		}
	},
	"required": ["AMS_OSCAR_JSON"],
	"uniqueItems": true,
	"additionalProperties": false,
	"maxItems": 1
}