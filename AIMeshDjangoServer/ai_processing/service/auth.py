from firebase_admin import auth


def check_firebase_token(firebase_token):
    """
    :param firebase_token:
    :return:
    """
    try:
        auth.verify_id_token(firebase_token)
        return True
    except auth.ExpiredIdTokenError:
        return False
    except auth.InvalidIdTokenError:
        return False
    except Exception as e:
        print("An error occurred while verifying the token: ", e)
        return False
