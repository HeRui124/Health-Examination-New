<script setup lang="ts">
import { ref, nextTick } from 'vue'
import { ElButton, ElInput } from 'element-plus'
import { ChatDotRound, Close } from '@element-plus/icons-vue'
import { chat } from '@/api/ai'

interface Message {
  role: 'user' | 'assistant'
  content: string
}

const visible = ref(false)
const input = ref('')
const messages = ref<Message[]>([
  { role: 'assistant', content: '你好！我是熙心体检智能助手，有什么可以帮你的吗？' }
])
const loading = ref(false)
const chatId = ref(`patient-${Date.now()}`)
const messagesRef = ref<HTMLDivElement>()

function toggle() {
  visible.value = !visible.value
}

function close() {
  visible.value = false
}

async function send() {
  const text = input.value.trim()
  if (!text || loading.value) return

  messages.value.push({ role: 'user', content: text })
  input.value = ''
  loading.value = true
  scrollToBottom()

  try {
    const res = await chat({ message: text, chatId: chatId.value })
    messages.value.push({ role: 'assistant', content: res.answer })
    chatId.value = res.chatId
  } catch (err: any) {
    let detail = ''
    if (err?.response) {
      detail = `状态码:${err.response.status} 响应:${JSON.stringify(err.response.data)}`
    } else if (err?.message) {
      detail = err.message
    } else {
      detail = String(err)
    }
    messages.value.push({ role: 'assistant', content: '服务异常：' + detail })
  } finally {
    loading.value = false
    nextTick(scrollToBottom)
  }
}

function handleKeydown(e: Event | KeyboardEvent) {
  if (e instanceof KeyboardEvent && e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    send()
  }
}

function scrollToBottom() {
  if (messagesRef.value) {
    messagesRef.value.scrollTop = messagesRef.value.scrollHeight
  }
}
</script>

<template>
  <div class="ai-chat-widget">
    <!-- 悬浮按钮 -->
    <div
      v-if="!visible"
      class="chat-float-btn"
      @click="toggle"
    >
      <el-icon :size="28" color="#fff"><ChatDotRound /></el-icon>
    </div>

    <!-- 聊天窗口 -->
    <div v-else class="chat-window">
      <div class="chat-header">
        <span class="chat-title">AI 智能助手</span>
        <el-icon class="chat-close" @click="close"><Close /></el-icon>
      </div>

      <div ref="messagesRef" class="chat-messages">
        <div
          v-for="(msg, index) in messages"
          :key="index"
          :class="['message', msg.role]"
        >
          <div class="bubble">{{ msg.content }}</div>
        </div>
        <div v-if="loading" class="message assistant">
          <div class="bubble loading">
            <span class="dot"></span>
            <span class="dot"></span>
            <span class="dot"></span>
          </div>
        </div>
      </div>

      <div class="chat-input-area">
        <el-input
          v-model="input"
          placeholder="输入问题..."
          size="small"
          :disabled="loading"
          @keydown="handleKeydown"
        />
        <el-button
          type="primary"
          size="small"
          :disabled="!input.trim() || loading"
          @click="send"
        >
          发送
        </el-button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.ai-chat-widget {
  position: absolute;
  bottom: 100px;
  right: 24px;
  z-index: 1000;
}

.chat-float-btn {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  background: linear-gradient(135deg, #10b981, #059669);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
  cursor: pointer;
  transition: transform 0.2s;
}

.chat-float-btn:active {
  transform: scale(0.95);
}

.chat-window {
  width: 320px;
  height: 460px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: linear-gradient(135deg, #10b981, #059669);
  color: white;
}

.chat-title {
  font-size: 15px;
  font-weight: 600;
}

.chat-close {
  cursor: pointer;
  font-size: 16px;
}

.chat-messages {
  flex: 1;
  padding: 12px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 10px;
  background: #f9fafb;
}

.message {
  display: flex;
}

.message.user {
  justify-content: flex-end;
}

.message.assistant {
  justify-content: flex-start;
}

.bubble {
  max-width: 80%;
  padding: 10px 12px;
  border-radius: 12px;
  font-size: 13px;
  line-height: 1.5;
  word-break: break-word;
}

.message.user .bubble {
  background: #10b981;
  color: white;
  border-bottom-right-radius: 4px;
}

.message.assistant .bubble {
  background: white;
  color: #374151;
  border: 1px solid #e5e7eb;
  border-bottom-left-radius: 4px;
}

.bubble.loading {
  display: flex;
  gap: 4px;
  align-items: center;
  padding: 12px 14px;
}

.dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #9ca3af;
  animation: bounce 1.4s infinite ease-in-out both;
}

.dot:nth-child(1) {
  animation-delay: -0.32s;
}

.dot:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

.chat-input-area {
  display: flex;
  gap: 8px;
  padding: 10px 12px;
  border-top: 1px solid #f3f4f6;
  background: white;
}

.chat-input-area :deep(.el-input__wrapper) {
  border-radius: 20px;
}
</style>
