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

// 拖动相关状态
const btnPosition = ref({ x: window.innerWidth - 80, y: window.innerHeight - 150 })
const isDragging = ref(false)
const dragStart = ref({ x: 0, y: 0 })
const btnOffset = ref({ x: 0, y: 0 })

function toggle() {
  // 如果正在拖动，不触发切换
  if (isDragging.value) return
  
  visible.value = !visible.value
  
  // 如果打开聊天窗口，将其居中
  if (visible.value) {
    nextTick(() => {
      centerChatWindow()
    })
  }
}

function centerChatWindow() {
  const widget = document.querySelector('.ai-chat-widget') as HTMLElement
  if (widget) {
    const windowWidth = window.innerWidth
    const windowHeight = window.innerHeight
    const chatWidth = 320
    const chatHeight = 460
    
    widget.style.left = `${(windowWidth - chatWidth) / 2}px`
    widget.style.top = `${(windowHeight - chatHeight) / 2}px`
    widget.style.right = 'auto'
    widget.style.bottom = 'auto'
  }
}

function close() {
  visible.value = false
}

// 拖动开始
function handleDragStart(e: MouseEvent | TouchEvent) {
  isDragging.value = false
  const clientX = e instanceof MouseEvent ? e.clientX : e.touches[0].clientX
  const clientY = e instanceof MouseEvent ? e.clientY : e.touches[0].clientY
  
  dragStart.value = { x: clientX, y: clientY }
  btnOffset.value = { x: clientX - btnPosition.value.x, y: clientY - btnPosition.value.y }
  
  const moveHandler = (moveEvent: MouseEvent | TouchEvent) => {
    const moveX = moveEvent instanceof MouseEvent ? moveEvent.clientX : moveEvent.touches[0].clientX
    const moveY = moveEvent instanceof MouseEvent ? moveEvent.clientY : moveEvent.touches[0].clientY
    
    const deltaX = Math.abs(moveX - dragStart.value.x)
    const deltaY = Math.abs(moveY - dragStart.value.y)
    
    // 如果移动距离超过5px，认为是拖动
    if (deltaX > 5 || deltaY > 5) {
      isDragging.value = true
    }
    
    if (isDragging.value) {
      btnPosition.value = {
        x: moveX - btnOffset.value.x,
        y: moveY - btnOffset.value.y
      }
    }
  }
  
  const endHandler = () => {
    document.removeEventListener('mousemove', moveHandler as any)
    document.removeEventListener('mouseup', endHandler)
    document.removeEventListener('touchmove', moveHandler as any)
    document.removeEventListener('touchend', endHandler)
    
    // 延迟重置，避免立即触发点击
    setTimeout(() => {
      isDragging.value = false
    }, 100)
  }
  
  document.addEventListener('mousemove', moveHandler as any)
  document.addEventListener('mouseup', endHandler)
  document.addEventListener('touchmove', moveHandler as any)
  document.addEventListener('touchend', endHandler)
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

// 简单的 Markdown 格式解析函数
function parseMarkdown(text: string): string {
  if (!text) return ''
  
  let html = text
  
  // 转义 HTML 特殊字符
  html = html.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  
  // 处理加粗 **text**
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
  
  // 处理斜体 *text*
  html = html.replace(/(?<!\*)\*([^*]+)\*(?!\*)/g, '<em>$1</em>')
  
  // 处理代码块 `code`
  html = html.replace(/`([^`]+)`/g, '<code class="inline-code">$1</code>')
  
  // 处理换行
  html = html.replace(/\n/g, '<br/>')
  
  return html
}
</script>

<template>
  <div class="ai-chat-widget">
    <!-- 悬浮按钮 -->
    <div
      v-if="!visible"
      class="chat-float-btn"
      :style="{
        left: btnPosition.x + 'px',
        top: btnPosition.y + 'px',
        right: 'auto',
        bottom: 'auto'
      }"
      @mousedown="handleDragStart"
      @touchstart="handleDragStart"
      @click.stop="toggle"
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
          <div v-if="msg.role === 'user'" class="bubble">{{ msg.content }}</div>
          <div v-else class="bubble assistant-content" v-html="parseMarkdown(msg.content)"></div>
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
  position: fixed;
  z-index: 1000;
}

.chat-float-btn {
  position: fixed;
  width: 52px;
  height: 52px;
  border-radius: 50%;
  background: linear-gradient(135deg, #10b981, #059669);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
  cursor: grab;
  transition: transform 0.2s;
  user-select: none;
  touch-action: none;
}

.chat-float-btn:active {
  cursor: grabbing;
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

/* AI 助手消息内容样式 */
.assistant-content {
  line-height: 1.6;
}

.assistant-content :deep(strong) {
  font-weight: 700;
  color: #1f2937;
}

.assistant-content :deep(em) {
  font-style: italic;
  color: #6b7280;
}

.assistant-content :deep(.inline-code) {
  background: #f3f4f6;
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 12px;
  color: #dc2626;
}

.assistant-content :deep(br) {
  display: block;
  margin: 4px 0;
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
