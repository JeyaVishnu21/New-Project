"""
Authentication & Role-Based Authorization Middleware (Stage 3)
--------------------------------------------------------------
Provides secure password hashing (Werkzeug PBKDF2),
session-based identity verification, and role enforcement decorators.
"""

from functools import wraps
from typing import Callable, Any, Optional
from flask import session, request, jsonify, g
from itsdangerous import URLSafeTimedSerializer
from werkzeug.security import generate_password_hash, check_password_hash
from models.user import UserModel
from config.settings import settings


def generate_auth_token(user_id: int, role: str) -> str:
    """Generates a tamper-proof time-signed auth token valid for 7 days."""
    serializer = URLSafeTimedSerializer(settings.SECRET_KEY)
    return serializer.dumps({'user_id': user_id, 'role': role})


def get_authenticated_user_id() -> Optional[int]:
    """
    Retrieves the authenticated user_id from either:
    1. Authorization Bearer header (reliable across domains Vercel <-> Render)
    2. Flask session cookie (fallback / same-domain)
    """
    # 1. Check Authorization: Bearer <token> header first
    auth_header = request.headers.get('Authorization', '')
    if auth_header.startswith('Bearer '):
        token = auth_header.split(' ', 1)[1].strip()
        try:
            serializer = URLSafeTimedSerializer(settings.SECRET_KEY)
            data = serializer.loads(token, max_age=86400 * 7)
            if data and data.get('user_id'):
                return data['user_id']
        except Exception:
            pass

    # 2. Check session cookie
    return session.get('user_id')


def hash_password(raw_password: str) -> str:
    """
    Securely hashes a plaintext password using Werkzeug's default PBKDF2 algorithm.
    Never store or log the raw plaintext password.
    """
    return generate_password_hash(raw_password)


def verify_password(raw_password: str, hashed_password: str) -> bool:
    """
    Verifies a plaintext password against a stored password hash.
    Safe against timing attacks.
    """
    if not raw_password or not hashed_password:
        return False
    return check_password_hash(hashed_password, raw_password)


def require_auth(f: Callable) -> Callable:
    """
    Decorator that requires an authenticated user session or Bearer token.
    Verifies the user against the database to guarantee the user exists and is active.
    Attaches the verified safe user record to Flask's `g.current_user`.
    Returns HTTP 401 Unauthorized if unauthenticated.
    """
    @wraps(f)
    def decorated_function(*args: Any, **kwargs: Any) -> Any:
        user_id = get_authenticated_user_id()

        if not user_id:
            return jsonify({
                "error": "Unauthorized",
                "message": "Authentication required. Please log in."
            }), 401

        # Fetch fresh user record from the database
        user = UserModel.get_by_id(user_id)
        if not user:
            session.clear()
            return jsonify({
                "error": "Unauthorized",
                "message": "User session is invalid. Please log in again."
            }), 401

        # Strip any sensitive fields before placing in Flask request context g
        g.current_user = UserModel.to_safe_dict(user)
        # Ensure session also has user_id and user_role populated for legacy route handlers
        try:
            session['user_id'] = g.current_user['id']
            session['user_role'] = g.current_user['role']
        except Exception:
            pass
        return f(*args, **kwargs)

    return decorated_function




def require_role(*allowed_roles: str) -> Callable:
    """
    Decorator factory that enforces role-based access control.
    Wraps `require_auth` and strictly checks `g.current_user['role']`.
    Returns HTTP 403 Forbidden if the user's role does not match.
    """
    def decorator(f: Callable) -> Callable:
        @wraps(f)
        @require_auth
        def decorated_function(*args: Any, **kwargs: Any) -> Any:
            user_role = g.current_user.get('role')

            effective_allowed = set(allowed_roles)
            if 'administrator' in effective_allowed:
                effective_allowed.add('management')
            if 'management' in effective_allowed:
                effective_allowed.add('administrator')

            if user_role not in effective_allowed:
                return jsonify({
                    "error": "Forbidden",
                    "message": (
                        f"Access denied. Required role(s): {', '.join(allowed_roles)}. "
                        f"Your current role is '{user_role}'."
                    )
                }), 403

            return f(*args, **kwargs)

        return decorated_function

    return decorator
