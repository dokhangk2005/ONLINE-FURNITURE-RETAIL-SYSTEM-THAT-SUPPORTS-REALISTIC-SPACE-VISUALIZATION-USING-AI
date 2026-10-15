const fs = require('fs');
const path = require('path');

let sequence = 1;
function makeId(prefix) {
  return 'FURN-CD-' + prefix + '-' + String(sequence++).padStart(6, '0') + '=';
}

const projectId = makeId('PROJECT');
const modelId = makeId('MODEL');

const colors = {
  identity: '#EAF2FF',
  catalog: '#EAF8EE',
  ordering: '#FFF3DD',
  intelligence: '#F4ECFF'
};

const definitions = [
  {
    name: 'Role', domain: 'identity', attributes: [
      ['RoleId', 'int', { pk: true }],
      ['RoleName', 'string']
    ], operations: [
      ['AssignToUser', [['userId', 'int']], 'void'],
      ['GetUsers', [], 'List<User>']
    ]
  },
  {
    name: 'User', domain: 'identity', attributes: [
      ['UserId', 'int', { pk: true }],
      ['RoleId', 'int', { fk: true }],
      ['Email', 'string'],
      ['PasswordHash', 'string'],
      ['FullName', 'string'],
      ['Phone', 'string'],
      ['Gender', 'string'],
      ['DateOfBirth', 'DateTime', { nullable: true }],
      ['IsDeleted', 'bool'],
      ['CreatedAt', 'DateTime'],
      ['UpdatedAt', 'DateTime', { nullable: true }],
      ['ResetPasswordOtp', 'string', { nullable: true }],
      ['ResetPasswordExpiry', 'DateTime', { nullable: true }],
      ['IsEmailVerified', 'bool'],
      ['RegistrationTokenHash', 'string', { nullable: true }],
      ['RegistrationTokenExpiry', 'DateTime', { nullable: true }],
      ['RegistrationEmailSentAt', 'DateTime', { nullable: true }],
      ['IsAvailableForDelivery', 'bool'],
      ['AvailabilityUpdatedAt', 'DateTime', { nullable: true }]
    ], operations: [
      ['Login', [['email', 'string'], ['password', 'string']], 'string'],
      ['QuickRegister', [['email', 'string']], 'User'],
      ['UpdateProfile', [['fullName', 'string'], ['phone', 'string']], 'void'],
      ['SetRole', [['roleId', 'int']], 'void'],
      ['ToggleStatus', [], 'void'],
      ['SetDeliveryAvailability', [['available', 'bool']], 'void']
    ]
  },
  {
    name: 'UserAddress', domain: 'identity', attributes: [
      ['AddressId', 'int', { pk: true }],
      ['UserId', 'int', { fk: true }],
      ['RecipientName', 'string'],
      ['Phone', 'string'],
      ['AddressLine', 'string'],
      ['Label', 'string', { nullable: true }],
      ['IsDefault', 'bool'],
      ['CreatedAt', 'DateTime'],
      ['UpdatedAt', 'DateTime', { nullable: true }]
    ], operations: [
      ['Create', [], 'UserAddress'],
      ['Update', [['addressLine', 'string']], 'void'],
      ['SetDefault', [], 'void'],
      ['Delete', [], 'void']
    ]
  },
  {
    name: 'SupportQuestion', domain: 'intelligence', attributes: [
      ['QuestionId', 'int', { pk: true }],
      ['UserId', 'int', { fk: true }],
      ['Topic', 'string'],
      ['QuestionText', 'string'],
      ['CreatedAt', 'DateTime'],
      ['AnswerText', 'string', { nullable: true }],
      ['AnsweredAt', 'DateTime', { nullable: true }],
      ['Status', 'string']
    ], operations: [
      ['Submit', [], 'SupportQuestion'],
      ['Answer', [['answer', 'string']], 'void'],
      ['MarkAnswered', [], 'void']
    ]
  },
  {
    name: 'RoomDesign', domain: 'intelligence', attributes: [
      ['RoomDesignId', 'Guid', { pk: true }],
      ['UserId', 'int', { nullable: true, fk: true }],
      ['Title', 'string'],
      ['RoomImagePath', 'string'],
      ['PreviewImagePath', 'string', { nullable: true }],
      ['AccessTokenHash', 'string'],
      ['SceneJson', 'string'],
      ['CreatedAt', 'DateTime'],
      ['UpdatedAt', 'DateTime'],
      ['ExpiresAt', 'DateTime', { nullable: true }]
    ], operations: [
      ['Create', [['title', 'string'], ['roomImage', 'byte[]']], 'RoomDesign'],
      ['AnalyzeRoom', [], 'string'],
      ['GeneratePreview', [['prompt', 'string']], 'byte[]'],
      ['SaveScene', [['sceneJson', 'string']], 'void'],
      ['Delete', [], 'void']
    ]
  },
  {
    name: 'Category', domain: 'catalog', attributes: [
      ['CategoryId', 'int', { pk: true }],
      ['CategoryName', 'string'],
      ['CategoryCode', 'string', { nullable: true }],
      ['ImageUrl', 'string', { nullable: true }],
      ['IsDeleted', 'bool'],
      ['CreatedAt', 'DateTime'],
      ['UpdatedAt', 'DateTime', { nullable: true }],
      ['ParentCategoryId', 'int', { nullable: true, fk: true }]
    ], operations: [
      ['CreateCategory', [], 'Category'],
      ['UpdateCategory', [['categoryId', 'int']], 'void'],
      ['DeleteCategory', [['categoryId', 'int']], 'void'],
      ['GetSubCategories', [], 'List<Category>']
    ]
  },
  {
    name: 'Product', domain: 'catalog', attributes: [
      ['ProductId', 'int', { pk: true }],
      ['CategoryId', 'int', { fk: true }],
      ['ProductName', 'string'],
      ['ProductCode', 'string', { nullable: true }],
      ['BasePrice', 'decimal'],
      ['Description', 'string', { nullable: true }],
      ['IsDeleted', 'bool'],
      ['CreatedAt', 'DateTime'],
      ['UpdatedAt', 'DateTime', { nullable: true }],
      ['AverageRating', 'double'],
      ['ReviewCount', 'int'],
      ['SoldCount', 'int', { transient: true }]
    ], operations: [
      ['GetDetails', [], 'Product'],
      ['UpdateInfo', [], 'void'],
      ['SoftDelete', [], 'void'],
      ['GetVariants', [], 'List<ProductVariant>'],
      ['GetRecommendations', [], 'List<Product>']
    ]
  },
  {
    name: 'Review', domain: 'catalog', attributes: [
      ['ReviewId', 'int', { pk: true }],
      ['ProductId', 'int', { fk: true }],
      ['UserId', 'int', { fk: true }],
      ['Rating', 'int'],
      ['Comment', 'string', { nullable: true }],
      ['IsApproved', 'bool'],
      ['CreatedAt', 'DateTime'],
      ['AdminReply', 'string', { nullable: true }],
      ['AdminReplyAt', 'DateTime', { nullable: true }]
    ], operations: [
      ['Submit', [], 'Review'],
      ['Approve', [], 'void'],
      ['Reject', [], 'void'],
      ['Reply', [['reply', 'string']], 'void']
    ]
  },
  {
    name: 'ProductRecommendation', domain: 'intelligence', attributes: [
      ['Id', 'int', { pk: true }],
      ['ProductId', 'int', { fk: true }],
      ['RecommendedProductId', 'int', { fk: true }],
      ['Confidence', 'decimal'],
      ['Support', 'decimal'],
      ['LastUpdated', 'DateTime']
    ], operations: [
      ['RebuildRules', [], 'int'],
      ['GetFrequentlyBoughtTogether', [['productId', 'int']], 'List<Product>'],
      ['GetSimilarProducts', [['productId', 'int']], 'List<Product>']
    ]
  },
  {
    name: 'RecommendationSetting', domain: 'intelligence', attributes: [
      ['Id', 'int', { pk: true }],
      ['AprioriEnabled', 'bool'],
      ['ContentBasedEnabled', 'bool'],
      ['AutoRebuildEnabled', 'bool'],
      ['MinSupport', 'decimal'],
      ['MinConfidence', 'decimal'],
      ['MaxResults', 'int'],
      ['UpdatedAt', 'DateTime']
    ], operations: [
      ['Update', [], 'RecommendationSetting'],
      ['EnableAutoRebuild', [['enabled', 'bool']], 'void'],
      ['ValidateThresholds', [], 'bool']
    ]
  },
  {
    name: 'ProductVariant', domain: 'catalog', attributes: [
      ['VariantId', 'int', { pk: true }],
      ['ProductId', 'int', { fk: true }],
      ['Material', 'string'],
      ['Color', 'string'],
      ['Size', 'string', { nullable: true }],
      ['AdditionalPrice', 'decimal'],
      ['StockQuantity', 'int'],
      ['IsDeleted', 'bool'],
      ['CreatedAt', 'DateTime'],
      ['UpdatedAt', 'DateTime', { nullable: true }]
    ], operations: [
      ['UpdateStock', [['quantity', 'int']], 'void'],
      ['GetSellingPrice', [['basePrice', 'decimal']], 'decimal'],
      ['IsInStock', [['quantity', 'int']], 'bool']
    ]
  },
  {
    name: 'ProductImage', domain: 'catalog', attributes: [
      ['ImageId', 'int', { pk: true }],
      ['VariantId', 'int', { fk: true }],
      ['ImageUrl', 'string'],
      ['IsThumbnail', 'bool'],
      ['CreatedAt', 'DateTime']
    ], operations: [
      ['Upload', [['file', 'byte[]']], 'ProductImage'],
      ['SetThumbnail', [], 'void'],
      ['RemoveBackground', [], 'byte[]']
    ]
  },
  {
    name: 'OrderDetail', domain: 'ordering', attributes: [
      ['OrderDetailId', 'int', { pk: true }],
      ['OrderId', 'int', { fk: true }],
      ['VariantId', 'int', { fk: true }],
      ['Quantity', 'int'],
      ['UnitPrice', 'decimal']
    ], operations: [
      ['CalculateSubtotal', [], 'decimal']
    ]
  },
  {
    name: 'Order', domain: 'ordering', attributes: [
      ['OrderId', 'int', { pk: true }],
      ['OrderCode', 'string', { nullable: true }],
      ['UserId', 'int', { fk: true }],
      ['ShipperId', 'int', { nullable: true, fk: true }],
      ['OrderDate', 'DateTime'],
      ['ShippingAddress', 'string'],
      ['RecipientName', 'string'],
      ['RecipientPhone', 'string'],
      ['RecipientEmail', 'string', { nullable: true }],
      ['CustomerNote', 'string', { nullable: true }],
      ['TotalAmount', 'decimal'],
      ['OrderStatus', 'string'],
      ['ShippingFee', 'decimal'],
      ['DeliveryDistanceKm', 'double', { nullable: true }],
      ['EstimatedDeliveryDate', 'DateTime', { nullable: true }],
      ['DeliveryTimeSlot', 'string', { nullable: true }],
      ['IncludesAssembly', 'bool'],
      ['AssemblyFee', 'decimal'],
      ['DeliveryProofImage', 'string', { nullable: true }],
      ['DeliveryNotes', 'string', { nullable: true }],
      ['DeliveryAttemptCount', 'int'],
      ['VoucherCode', 'string', { nullable: true, logicalRef: true }],
      ['UpdatedAt', 'DateTime', { nullable: true }]
    ], operations: [
      ['CreateOrder', [], 'Order'],
      ['CalculateTotal', [], 'decimal'],
      ['CalculateShipping', [], 'decimal'],
      ['UpdateStatus', [['status', 'string']], 'void'],
      ['AssignShipper', [['shipperId', 'int']], 'void'],
      ['ReportDeliveryIssue', [['reason', 'string']], 'void'],
      ['Reschedule', [['deliveryDate', 'DateTime'], ['timeSlot', 'string']], 'void'],
      ['CompleteDelivery', [['proofImage', 'string']], 'void']
    ]
  },
  {
    name: 'Payment', domain: 'ordering', attributes: [
      ['PaymentId', 'int', { pk: true }],
      ['OrderId', 'int', { fk: true }],
      ['PaymentMethod', 'string'],
      ['Amount', 'decimal'],
      ['PaymentDate', 'DateTime'],
      ['TransactionId', 'string'],
      ['PaymentStatus', 'string'],
      ['UpdatedAt', 'DateTime', { nullable: true }]
    ], operations: [
      ['GenerateVnPayUrl', [], 'string'],
      ['VerifyVnPayResponse', [['signature', 'string']], 'bool'],
      ['UpdateStatus', [['status', 'string']], 'void']
    ]
  },
  {
    name: 'Voucher', domain: 'ordering', attributes: [
      ['VoucherId', 'int', { pk: true }],
      ['VoucherCode', 'string'],
      ['VoucherName', 'string'],
      ['Description', 'string', { nullable: true }],
      ['DiscountType', 'int'],
      ['DiscountValue', 'decimal'],
      ['MaxDiscountAmount', 'decimal', { nullable: true }],
      ['MinOrderAmount', 'decimal'],
      ['UsageLimit', 'int'],
      ['UsedCount', 'int'],
      ['StartDate', 'DateTime'],
      ['EndDate', 'DateTime'],
      ['IsActive', 'bool'],
      ['CreatedAt', 'DateTime'],
      ['UpdatedAt', 'DateTime', { nullable: true }]
    ], operations: [
      ['Validate', [['orderAmount', 'decimal']], 'bool'],
      ['CalculateDiscount', [['orderAmount', 'decimal']], 'decimal'],
      ['Activate', [], 'void'],
      ['Deactivate', [], 'void']
    ]
  }
];

const classes = new Map();

for (const definition of definitions) {
  const classId = makeId('CLASS');
  const modelAttributes = [];
  const attributeMetadata = [];
  for (const item of definition.attributes) {
    const name = item[0];
    const type = item[1];
    const options = item[2] || {};
    const attributeId = makeId('ATTR');
    const attribute = {
      _type: 'UMLAttribute',
      _id: attributeId,
      _parent: { $ref: classId },
      name: name,
      type: type,
      visibility: 'public'
    };
    if (options.nullable) attribute.multiplicity = '0..1';
    if (options.pk) attribute.isID = true;
    if (options.transient) attribute.isDerived = true;
    modelAttributes.push(attribute);
    attributeMetadata.push({ id: attributeId, name: name, type: type, options: options });
  }
  const modelOperations = [];
  const operationMetadata = [];
  for (const operationItem of definition.operations || []) {
    const operationName = operationItem[0];
    const parameterDefinitions = operationItem[1] || [];
    const returnType = operationItem[2] || 'void';
    const operationId = makeId('OPERATION');
    const parameters = parameterDefinitions.map(function (parameterDefinition) {
      return {
        _type: 'UMLParameter',
        _id: makeId('PARAM'),
        _parent: { $ref: operationId },
        name: parameterDefinition[0],
        type: parameterDefinition[1],
        direction: 'in'
      };
    });
    parameters.push({
      _type: 'UMLParameter',
      _id: makeId('PARAM'),
      _parent: { $ref: operationId },
      type: returnType,
      direction: 'return'
    });
    const operation = {
      _type: 'UMLOperation',
      _id: operationId,
      _parent: { $ref: classId },
      name: operationName,
      visibility: 'public',
      parameters: parameters
    };
    modelOperations.push(operation);
    operationMetadata.push({
      id: operationId,
      name: operationName,
      parameters: parameterDefinitions,
      returnType: returnType
    });
  }
  const classModel = {
    _type: 'UMLClass',
    _id: classId,
    _parent: { $ref: modelId },
    name: definition.name,
    ownedElements: [],
    attributes: modelAttributes,
    operations: modelOperations
  };
  classes.set(definition.name, {
    definition: definition,
    model: classModel,
    attributes: attributeMetadata,
    operations: operationMetadata
  });
}

const relationDefinitions = [
  { key: 'RoleUsers', source: 'Role', target: 'User', name: 'has users', label: '', tail: '1', head: '0..*', targetRole: 'Users' },
  { key: 'UserOrdersCustomer', source: 'User', target: 'Order', name: 'places orders', label: 'customer', tail: '1', head: '0..*', targetRole: 'Orders' },
  { key: 'UserOrdersShipper', source: 'User', target: 'Order', name: 'delivers orders', label: 'shipper', tail: '0..1', head: '0..*', targetRole: 'ShippedOrders' },
  { key: 'UserReviews', source: 'User', target: 'Review', name: 'writes reviews', label: '', tail: '1', head: '0..*', targetRole: 'Reviews' },
  { key: 'UserSupport', source: 'User', target: 'SupportQuestion', name: 'asks questions', label: '', tail: '1', head: '0..*', targetRole: 'SupportQuestions' },
  { key: 'UserAddresses', source: 'User', target: 'UserAddress', name: 'owns addresses', label: '', tail: '1', head: '0..*', targetRole: 'Addresses', aggregation: 'composite' },
  { key: 'UserDesigns', source: 'User', target: 'RoomDesign', name: 'owns room designs', label: '', tail: '0..1', head: '0..*', targetRole: 'RoomDesigns' },
  { key: 'CategoryParent', source: 'Category', target: 'Category', name: 'parent category', label: 'parent / child', tail: '0..1', head: '0..*', sourceRole: 'ParentCategory', targetRole: 'SubCategories', aggregation: 'shared' },
  { key: 'CategoryProducts', source: 'Category', target: 'Product', name: 'contains products', label: '', tail: '1', head: '0..*', targetRole: 'Products' },
  { key: 'ProductVariants', source: 'Product', target: 'ProductVariant', name: 'has variants', label: '', tail: '1', head: '0..*', targetRole: 'ProductVariants', aggregation: 'composite' },
  { key: 'VariantImages', source: 'ProductVariant', target: 'ProductImage', name: 'has images', label: '', tail: '1', head: '0..*', targetRole: 'ProductImages', aggregation: 'composite' },
  { key: 'VariantOrderDetails', source: 'ProductVariant', target: 'OrderDetail', name: 'appears in order details', label: '', tail: '1', head: '0..*', targetRole: 'OrderDetails' },
  { key: 'ProductReviews', source: 'Product', target: 'Review', name: 'receives reviews', label: '', tail: '1', head: '0..*', targetRole: 'Reviews' },
  { key: 'ProductRecSource', source: 'Product', target: 'ProductRecommendation', name: 'recommendation source', label: 'source', tail: '1', head: '0..*', targetRole: 'Recommendations' },
  { key: 'ProductRecRecommended', source: 'Product', target: 'ProductRecommendation', name: 'recommended product', label: 'recommended', tail: '1', head: '0..*', targetRole: 'RecommendedIn' },
  { key: 'OrderDetails', source: 'Order', target: 'OrderDetail', name: 'contains details', label: '', tail: '1', head: '0..*', targetRole: 'OrderDetails', aggregation: 'composite' },
  { key: 'OrderPayments', source: 'Order', target: 'Payment', name: 'has payment attempts', label: '', tail: '1', head: '0..*', targetRole: 'Payments', aggregation: 'composite' }
];

const relations = new Map();
for (const definition of relationDefinitions) {
  const associationId = makeId('ASSOC');
  const end1Id = makeId('END');
  const end2Id = makeId('END');
  const end1 = {
    _type: 'UMLAssociationEnd',
    _id: end1Id,
    _parent: { $ref: associationId },
    name: definition.sourceRole || '',
    reference: { $ref: classes.get(definition.source).model._id },
    multiplicity: definition.tail
  };
  if (definition.aggregation) end1.aggregation = definition.aggregation;
  const end2 = {
    _type: 'UMLAssociationEnd',
    _id: end2Id,
    _parent: { $ref: associationId },
    name: definition.targetRole || '',
    reference: { $ref: classes.get(definition.target).model._id },
    multiplicity: definition.head
  };
  const association = {
    _type: 'UMLAssociation',
    _id: associationId,
    _parent: { $ref: classes.get(definition.source).model._id },
    name: definition.name,
    end1: end1,
    end2: end2
  };
  classes.get(definition.source).model.ownedElements.push(association);
  relations.set(definition.key, { definition: definition, model: association, end1: end1, end2: end2 });
}

const voucherDependencyId = makeId('DEPENDENCY');
const voucherDependency = {
  _type: 'UMLDependency',
  _id: voucherDependencyId,
  _parent: { $ref: classes.get('Order').model._id },
  name: 'lookup by VoucherCode',
  source: { $ref: classes.get('Order').model._id },
  target: { $ref: classes.get('Voucher').model._id }
};
classes.get('Order').model.ownedElements.push(voucherDependency);

function attributeText(metadata) {
  let text = '+' + metadata.name + ': ' + metadata.type;
  if (metadata.options.nullable) text += '[0..1]';
  const markers = [];
  if (metadata.options.pk) markers.push('id');
  if (metadata.options.fk) markers.push('FK');
  if (metadata.options.logicalRef) markers.push('logical reference');
  if (metadata.options.transient) markers.push('transient');
  if (markers.length > 0) text += ' {' + markers.join(', ') + '}';
  return text;
}

function operationText(metadata) {
  const parameters = metadata.parameters.map(function (parameter) {
    return parameter[0] + ': ' + parameter[1];
  }).join(', ');
  return '+' + metadata.name + '(' + parameters + '): ' + metadata.returnType;
}

function hiddenLabel(parentId, font) {
  return {
    _type: 'LabelView',
    _id: makeId('LABEL'),
    _parent: { $ref: parentId },
    visible: false,
    font: font,
    left: -48,
    top: -48,
    width: 10,
    height: 13
  };
}

function buildClassView(diagramId, classEntry, layout, showAttributes) {
  const viewId = makeId('CLASSVIEW');
  const nameCompartmentId = makeId('NAMECOMP');
  const stereotypeLabel = hiddenLabel(nameCompartmentId, 'Arial;12;0');
  const nameLabel = {
    _type: 'LabelView',
    _id: makeId('NAMELABEL'),
    _parent: { $ref: nameCompartmentId },
    font: 'Arial;13;1',
    left: layout.x + 5,
    top: layout.y + 7,
    width: layout.w - 10,
    height: 15,
    text: classEntry.definition.name,
    horizontalAlignment: 1
  };
  const namespaceLabel = hiddenLabel(nameCompartmentId, 'Arial;12;0');
  const propertyLabel = hiddenLabel(nameCompartmentId, 'Arial;12;0');
  const nameCompartment = {
    _type: 'UMLNameCompartmentView',
    _id: nameCompartmentId,
    _parent: { $ref: viewId },
    model: { $ref: classEntry.model._id },
    subViews: [stereotypeLabel, nameLabel, namespaceLabel, propertyLabel],
    font: 'Arial;12;0',
    left: layout.x,
    top: layout.y,
    width: layout.w,
    height: 28,
    stereotypeLabel: { $ref: stereotypeLabel._id },
    nameLabel: { $ref: nameLabel._id },
    namespaceLabel: { $ref: namespaceLabel._id },
    propertyLabel: { $ref: propertyLabel._id }
  };

  const attributeCompartmentId = makeId('ATTRCOMP');
  const attributeViews = [];
  if (showAttributes) {
    classEntry.attributes.forEach(function (attribute, index) {
      attributeViews.push({
        _type: 'UMLAttributeView',
        _id: makeId('ATTRVIEW'),
        _parent: { $ref: attributeCompartmentId },
        model: { $ref: attribute.id },
        font: 'Arial;12;0',
        left: layout.x + 5,
        top: layout.y + 33 + index * 15,
        width: layout.w - 10,
        height: 13,
        text: attributeText(attribute),
        horizontalAlignment: 0
      });
    });
  }
  const attributeHeight = showAttributes ? classEntry.attributes.length * 15 + 10 : 10;
  const attributeCompartment = {
    _type: 'UMLAttributeCompartmentView',
    _id: attributeCompartmentId,
    _parent: { $ref: viewId },
    model: { $ref: classEntry.model._id },
    visible: showAttributes,
    subViews: attributeViews,
    font: 'Arial;12;0',
    left: layout.x,
    top: layout.y + 28,
    width: layout.w,
    height: attributeHeight
  };

  function hiddenCompartment(type, prefix) {
    return {
      _type: type,
      _id: makeId(prefix),
      _parent: { $ref: viewId },
      model: { $ref: classEntry.model._id },
      visible: false,
      font: 'Arial;12;0',
      left: -48,
      top: -48,
      width: 10,
      height: 10
    };
  }

  const operationCompartmentId = makeId('OPCOMP');
  const operationViews = [];
  if (showAttributes) {
    classEntry.operations.forEach(function (operation, index) {
      operationViews.push({
        _type: 'UMLOperationView',
        _id: makeId('OPVIEW'),
        _parent: { $ref: operationCompartmentId },
        model: { $ref: operation.id },
        font: 'Arial;12;0',
        left: layout.x + 5,
        top: layout.y + 33 + attributeHeight + index * 15,
        width: layout.w - 10,
        height: 13,
        text: operationText(operation),
        horizontalAlignment: 0
      });
    });
  }
  const operationHeight = showAttributes ? classEntry.operations.length * 15 + 10 : 10;
  const operationCompartment = {
    _type: 'UMLOperationCompartmentView',
    _id: operationCompartmentId,
    _parent: { $ref: viewId },
    model: { $ref: classEntry.model._id },
    visible: showAttributes,
    subViews: operationViews,
    font: 'Arial;12;0',
    left: layout.x,
    top: layout.y + 28 + attributeHeight,
    width: layout.w,
    height: operationHeight
  };
  const receptionCompartment = hiddenCompartment('UMLReceptionCompartmentView', 'RECCOMP');
  const templateCompartment = hiddenCompartment('UMLTemplateParameterCompartmentView', 'TMPCOMP');
  const height = showAttributes ? 28 + attributeHeight + operationHeight : 55;

  return {
    _type: 'UMLClassView',
    _id: viewId,
    _parent: { $ref: diagramId },
    model: { $ref: classEntry.model._id },
    subViews: [nameCompartment, attributeCompartment, operationCompartment, receptionCompartment, templateCompartment],
    font: 'Arial;12;0',
    fillColor: showAttributes ? '#FFFFFF' : colors[classEntry.definition.domain],
    lineColor: '#4D5968',
    containerChangeable: true,
    left: layout.x,
    top: layout.y,
    width: layout.w,
    height: height,
    nameCompartment: { $ref: nameCompartmentId },
    suppressAttributes: !showAttributes,
    suppressOperations: !showAttributes,
    attributeCompartment: { $ref: attributeCompartmentId },
    operationCompartment: { $ref: operationCompartment._id },
    receptionCompartment: { $ref: receptionCompartment._id },
    templateParameterCompartment: { $ref: templateCompartment._id }
  };
}

function edgeLabel(parentId, modelIdRef, options) {
  const label = {
    _type: 'EdgeLabelView',
    _id: makeId('EDGELABEL'),
    _parent: { $ref: parentId },
    model: { $ref: modelIdRef },
    font: 'Arial;12;0',
    left: options.x,
    top: options.y,
    width: options.width || 80,
    height: 13,
    alpha: options.alpha,
    distance: options.distance,
    hostEdge: { $ref: parentId }
  };
  if (options.edgePosition !== undefined) label.edgePosition = options.edgePosition;
  if (options.visible === false) label.visible = false;
  if (options.text) label.text = options.text;
  return label;
}

function pointString(points) {
  return points.map(function (point) { return point[0] + ':' + point[1]; }).join(';');
}

function buildAssociationView(diagramId, relation, classViews, route) {
  const viewId = makeId('ASSOCVIEW');
  const points = route.points;
  const first = points[0];
  const last = points[points.length - 1];
  const labelPoint = route.label || points[Math.floor(points.length / 2)];

  const nameLabel = edgeLabel(viewId, relation.model._id, {
    x: labelPoint[0] + 6, y: labelPoint[1] - 18, width: 115,
    alpha: Math.PI / 2, distance: 15, edgePosition: 1,
    visible: Boolean(relation.definition.label), text: relation.definition.label
  });
  const stereotypeLabel = edgeLabel(viewId, relation.model._id, {
    x: labelPoint[0], y: labelPoint[1], alpha: Math.PI / 2, distance: 30,
    edgePosition: 1, visible: false
  });
  const propertyLabel = edgeLabel(viewId, relation.model._id, {
    x: labelPoint[0], y: labelPoint[1], alpha: -Math.PI / 2, distance: 15,
    edgePosition: 1, visible: false
  });
  const tailRoleNameLabel = edgeLabel(viewId, relation.end1._id, {
    x: first[0] + 8, y: first[1] - 28, alpha: Math.PI / 6, distance: 30,
    edgePosition: 2, visible: false
  });
  const tailPropertyLabel = edgeLabel(viewId, relation.end1._id, {
    x: first[0] + 8, y: first[1] - 14, alpha: Math.PI / 4, distance: 40,
    edgePosition: 2, visible: false
  });
  const tailMultiplicityLabel = edgeLabel(viewId, relation.end1._id, {
    x: first[0] + 6, y: first[1] + 4, width: 42,
    alpha: -Math.PI / 6, distance: 25, edgePosition: 2,
    text: relation.definition.tail
  });
  const headRoleNameLabel = edgeLabel(viewId, relation.end2._id, {
    x: last[0] - 54, y: last[1] - 28, alpha: -Math.PI / 6, distance: 30,
    visible: false
  });
  const headPropertyLabel = edgeLabel(viewId, relation.end2._id, {
    x: last[0] - 54, y: last[1] - 14, alpha: -Math.PI / 4, distance: 40,
    visible: false
  });
  const headMultiplicityLabel = edgeLabel(viewId, relation.end2._id, {
    x: last[0] - 48, y: last[1] + 4, width: 42,
    alpha: Math.PI / 6, distance: 25,
    text: relation.definition.head
  });
  const tailQualifier = {
    _type: 'UMLQualifierCompartmentView', _id: makeId('QUALIFIER'),
    _parent: { $ref: viewId }, model: { $ref: relation.end1._id }, visible: false,
    font: 'Arial;12;0', left: -48, top: -48, width: 10, height: 10
  };
  const headQualifier = {
    _type: 'UMLQualifierCompartmentView', _id: makeId('QUALIFIER'),
    _parent: { $ref: viewId }, model: { $ref: relation.end2._id }, visible: false,
    font: 'Arial;12;0', left: -48, top: -48, width: 10, height: 10
  };

  return {
    _type: 'UMLAssociationView',
    _id: viewId,
    _parent: { $ref: diagramId },
    model: { $ref: relation.model._id },
    subViews: [
      nameLabel, stereotypeLabel, propertyLabel,
      tailRoleNameLabel, tailPropertyLabel, tailMultiplicityLabel,
      headRoleNameLabel, headPropertyLabel, headMultiplicityLabel,
      tailQualifier, headQualifier
    ],
    font: 'Arial;12;0',
    lineColor: '#5B6573',
    head: { $ref: classViews.get(relation.definition.target)._id },
    tail: { $ref: classViews.get(relation.definition.source)._id },
    points: pointString(points),
    showVisibility: true,
    nameLabel: { $ref: nameLabel._id },
    stereotypeLabel: { $ref: stereotypeLabel._id },
    propertyLabel: { $ref: propertyLabel._id },
    tailRoleNameLabel: { $ref: tailRoleNameLabel._id },
    tailPropertyLabel: { $ref: tailPropertyLabel._id },
    tailMultiplicityLabel: { $ref: tailMultiplicityLabel._id },
    headRoleNameLabel: { $ref: headRoleNameLabel._id },
    headPropertyLabel: { $ref: headPropertyLabel._id },
    headMultiplicityLabel: { $ref: headMultiplicityLabel._id },
    tailQualifiersCompartment: { $ref: tailQualifier._id },
    headQualifiersCompartment: { $ref: headQualifier._id }
  };
}

function buildDependencyView(diagramId, classViews, route) {
  const viewId = makeId('DEPVIEW');
  const points = route.points;
  const labelPoint = route.label || points[Math.floor(points.length / 2)];
  const nameLabel = edgeLabel(viewId, voucherDependencyId, {
    x: labelPoint[0] + 6, y: labelPoint[1] - 18, width: 145,
    alpha: Math.PI / 2, distance: 15, edgePosition: 1,
    text: 'lookup by VoucherCode'
  });
  const stereotypeLabel = edgeLabel(viewId, voucherDependencyId, {
    x: labelPoint[0], y: labelPoint[1], alpha: Math.PI / 2,
    distance: 30, edgePosition: 1, visible: false
  });
  const propertyLabel = edgeLabel(viewId, voucherDependencyId, {
    x: labelPoint[0], y: labelPoint[1], alpha: -Math.PI / 2,
    distance: 15, edgePosition: 1, visible: false
  });
  return {
    _type: 'UMLDependencyView',
    _id: viewId,
    _parent: { $ref: diagramId },
    model: { $ref: voucherDependencyId },
    subViews: [nameLabel, stereotypeLabel, propertyLabel],
    font: 'Arial;12;0',
    lineColor: '#8A6D3B',
    head: { $ref: classViews.get('Voucher')._id },
    tail: { $ref: classViews.get('Order')._id },
    points: pointString(points),
    showVisibility: true,
    nameLabel: { $ref: nameLabel._id },
    stereotypeLabel: { $ref: stereotypeLabel._id },
    propertyLabel: { $ref: propertyLabel._id }
  };
}

const overviewLayouts = {
  Role: { x: 60, y: 60, w: 220 },
  User: { x: 60, y: 180, w: 220 },
  UserAddress: { x: 60, y: 330, w: 220 },
  SupportQuestion: { x: 60, y: 460, w: 220 },
  RoomDesign: { x: 60, y: 590, w: 220 },
  Category: { x: 420, y: 60, w: 220 },
  Product: { x: 420, y: 210, w: 220 },
  Review: { x: 420, y: 380, w: 220 },
  ProductRecommendation: { x: 420, y: 530, w: 220 },
  RecommendationSetting: { x: 420, y: 680, w: 220 },
  ProductVariant: { x: 780, y: 150, w: 220 },
  ProductImage: { x: 780, y: 330, w: 220 },
  OrderDetail: { x: 780, y: 500, w: 220 },
  Order: { x: 1140, y: 180, w: 220 },
  Payment: { x: 1500, y: 160, w: 220 },
  Voucher: { x: 1500, y: 380, w: 220 }
};

const detailLayouts = {
  Role: { x: 70, y: 70, w: 400 },
  User: { x: 70, y: 260, w: 400 },
  UserAddress: { x: 70, y: 780, w: 400 },
  SupportQuestion: { x: 70, y: 1110, w: 400 },
  RoomDesign: { x: 70, y: 1410, w: 400 },
  Category: { x: 600, y: 70, w: 420 },
  Product: { x: 600, y: 380, w: 420 },
  Review: { x: 600, y: 780, w: 420 },
  ProductRecommendation: { x: 600, y: 1110, w: 420 },
  RecommendationSetting: { x: 600, y: 1410, w: 420 },
  ProductVariant: { x: 1150, y: 200, w: 450 },
  ProductImage: { x: 1150, y: 560, w: 450 },
  OrderDetail: { x: 1150, y: 900, w: 450 },
  Order: { x: 1700, y: 260, w: 450 },
  Payment: { x: 2250, y: 260, w: 440 },
  Voucher: { x: 2250, y: 620, w: 440 }
};

const overviewRoutes = {
  RoleUsers: { points: [[170, 115], [170, 180]] },
  UserOrdersCustomer: { points: [[280, 190], [320, 190], [320, 25], [1200, 25], [1200, 180]], label: [700, 25] },
  UserOrdersShipper: { points: [[280, 215], [340, 215], [340, 45], [1280, 45], [1280, 180]], label: [920, 45] },
  UserReviews: { points: [[280, 210], [350, 210], [350, 407], [420, 407]] },
  UserSupport: { points: [[60, 210], [30, 210], [30, 487], [60, 487]] },
  UserAddresses: { points: [[170, 235], [170, 330]] },
  UserDesigns: { points: [[60, 220], [15, 220], [15, 617], [60, 617]] },
  CategoryParent: { points: [[420, 75], [390, 75], [390, 105], [420, 105]], label: [382, 90] },
  CategoryProducts: { points: [[530, 115], [530, 210]] },
  ProductVariants: { points: [[640, 237], [710, 237], [710, 177], [780, 177]] },
  VariantImages: { points: [[890, 205], [890, 330]] },
  VariantOrderDetails: { points: [[1000, 177], [1060, 177], [1060, 527], [1000, 527]] },
  ProductReviews: { points: [[530, 265], [530, 380]] },
  ProductRecSource: { points: [[470, 265], [380, 265], [380, 557], [420, 557]], label: [380, 500] },
  ProductRecRecommended: { points: [[590, 265], [690, 265], [690, 580], [640, 580]], label: [690, 500] },
  OrderDetails: { points: [[1140, 207], [1100, 207], [1100, 527], [1000, 527]] },
  OrderPayments: { points: [[1360, 200], [1430, 200], [1430, 187], [1500, 187]] }
};

const detailRoutes = {
  RoleUsers: { points: [[270, 178], [270, 260]] },
  UserOrdersCustomer: { points: [[470, 330], [520, 330], [520, 25], [1810, 25], [1810, 260]], label: [1120, 25] },
  UserOrdersShipper: { points: [[470, 390], [550, 390], [550, 50], [1980, 50], [1980, 260]], label: [1450, 50] },
  UserReviews: { points: [[470, 500], [535, 500], [535, 900], [600, 900]] },
  UserSupport: { points: [[70, 500], [35, 500], [35, 1215], [70, 1215]] },
  UserAddresses: { points: [[270, 683], [270, 780]] },
  UserDesigns: { points: [[70, 560], [18, 560], [18, 1545], [70, 1545]] },
  CategoryParent: { points: [[600, 115], [550, 115], [550, 235], [600, 235]], label: [540, 170] },
  CategoryProducts: { points: [[810, 298], [810, 380]] },
  ProductVariants: { points: [[1020, 520], [1080, 520], [1080, 320], [1150, 320]] },
  VariantImages: { points: [[1375, 443], [1375, 560]] },
  VariantOrderDetails: { points: [[1600, 320], [1640, 320], [1640, 970], [1600, 970]] },
  ProductReviews: { points: [[810, 683], [810, 780]] },
  ProductRecSource: { points: [[700, 683], [570, 683], [570, 1170], [600, 1170]], label: [570, 1060] },
  ProductRecRecommended: { points: [[920, 683], [1080, 683], [1080, 1230], [1020, 1230]], label: [1080, 1060] },
  OrderDetails: { points: [[1700, 700], [1665, 700], [1665, 1000], [1600, 1000]] },
  OrderPayments: { points: [[2150, 400], [2200, 400], [2200, 360], [2250, 360]] }
};

function buildDiagram(name, layouts, routes, showAttributes, dependencyRoute) {
  const diagramId = makeId('DIAGRAM');
  const classViews = new Map();
  const ownedViews = [];
  for (const definition of definitions) {
    const view = buildClassView(diagramId, classes.get(definition.name), layouts[definition.name], showAttributes);
    classViews.set(definition.name, view);
    ownedViews.push(view);
  }
  for (const definition of relationDefinitions) {
    ownedViews.push(buildAssociationView(diagramId, relations.get(definition.key), classViews, routes[definition.key]));
  }
  ownedViews.push(buildDependencyView(diagramId, classViews, dependencyRoute));
  return {
    _type: 'UMLClassDiagram',
    _id: diagramId,
    _parent: { $ref: modelId },
    name: name,
    defaultDiagram: showAttributes,
    visible: true,
    ownedViews: ownedViews
  };
}

const overviewDiagram = buildDiagram(
  '01 - Tổng quan miền nghiệp vụ',
  overviewLayouts,
  overviewRoutes,
  false,
  { points: [[1360, 220], [1430, 220], [1430, 407], [1500, 407]], label: [1430, 330] }
);

const detailDiagram = buildDiagram(
  '02 - Class Diagram đầy đủ (thuộc tính và phương thức)',
  detailLayouts,
  detailRoutes,
  true,
  { points: [[2150, 650], [2200, 650], [2200, 800], [2250, 800]], label: [2200, 740] }
);

const umlModel = {
  _type: 'UMLModel',
  _id: modelId,
  _parent: { $ref: projectId },
  name: 'Furniture System Domain Model',
  ownedElements: [overviewDiagram, detailDiagram].concat(definitions.map(function (definition) {
    return classes.get(definition.name).model;
  }))
};

const project = {
  _type: 'Project',
  _id: projectId,
  name: 'Class Diagram - Furniture E-commerce System',
  ownedElements: [umlModel]
};

const outputPath = path.resolve(__dirname, '..', 'Class_Diagram_Furniture_System_Attributes_Operations.mdj');
fs.writeFileSync(outputPath, JSON.stringify(project, null, 2) + '\n', 'utf8');
process.stdout.write(outputPath + '\n');
