import json

VALID_REGIONS = [
    'us-east-1', 'us-west-1', 'us-west-2',
    'eu-west-1', 'eu-central-1',
    'ap-southeast-1', 'ap-southeast-2', 'ap-northeast-1',
    'sa-east-1'
]

def validate_slot(slot_value, slot_name):
    """Validate the slot value."""
    if slot_name == 'Region' and slot_value not in VALID_REGIONS:
        return False
    return True

def elicit_slot(intent_name, slots, slot_to_elicit, message):
    """Return a dialog action to elicit a slot."""
    return {
        'dialogAction': {
            'type': 'ElicitSlot',
            'intentName': intent_name,
            'slots': slots,
            'slotToElicit': slot_to_elicit,
            'message': {
                'contentType': 'PlainText',
                'content': message
            }
        }
    }

def delegate(slots):
    """Delegate the conversation back to Lex."""
    return {
        'dialogAction': {
            'type': 'Delegate',
            'slots': slots
        }
    }

def lambda_handler(event, context):
    intent_name = event['currentIntent']['name']
    slots = event['currentIntent']['slots']
    region = slots.get('Region')

    # Validate the region slot
    if region and not validate_slot(region, 'Region'):
        return elicit_slot(intent_name, slots, 'Region', 'The region "{}" is not valid. Please choose a valid AWS region.'.format(region))

    # Delegate to Lex if all slots are valid
    return delegate(slots)
